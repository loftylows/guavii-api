defmodule ApiGatewayWeb.Gql.Resolvers.User do
  def get_user(_, %{where: %{id: user_id}}, _) do
    {:ok, ApiGateway.Models.Account.User.get_user(user_id)}
  end

  def get_users(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Account.User.get_users(filters)}
  end

  def get_users(_, _, _) do
    {:ok, ApiGateway.Models.Account.User.get_users()}
  end

  def create_user(_, %{data: data}, _) do
    case ApiGateway.Models.Account.User.create_user(data) do
      {:ok, user} ->
        {:ok, user}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "User input error",
          errors
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def update_user(_, %{data: data, where: %{id: id}}, _) do
    case ApiGateway.Models.Account.User.update_user(%{id: id, data: data}) do
      {:ok, user} ->
        {:ok, user}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def delete_user(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Account.User.delete_user(id) do
      {:ok, user} ->
        {:ok, user}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User not found")
    end
  end

  ####################
  # Other resolvers #
  ####################
  def check_user_email_unused_in_workspace(
        _,
        %{input: %{email: email, workspace_id: workspace_id}},
        _
      ) do
    is_unused? =
      %{email_in: email, workspace_id: workspace_id}
      |> ApiGateway.Models.Account.User.get_users()
      |> Enum.empty?()

    {:ok, is_unused?}
  end

  def register_user_and_workspace(
        _,
        %{
          data: %{
            token: token,
            encoded_email_connected_to_invitation: base_64_url_encoded_email,
            create_user_with_workspace_registration_input: user_info,
            create_workspace_with_user_registration_input: workspace_info
          }
        },
        _
      ) do
    ApiGateway.Models.Account.Registration.register_user_and_workspace(
      token,
      base_64_url_encoded_email,
      user_info,
      workspace_info
    )
    |> case do
      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, reason} when is_binary(reason) ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error(reason)

      {:ok, payload} ->
        {:ok, payload}
    end
  end

  # make sure that the user is not already logged in with this guard
  def login_user_with_email_and_password(_, _, %{context: %{current_user: user}})
      when is_map(user) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error("You are already logged into this workspace")
  end

  # make sure that the user is logging into a workspace because 'current_subdomain' should be set
  def login_user_with_email_and_password(_, _, %{context: %{current_subdomain: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def login_user_with_email_and_password(
        _,
        %{
          data: %{
            email: email,
            password: password
          }
        },
        %{context: %{current_subdomain: subdomain}}
      ) do
    ApiGateway.Models.Account.User.authenticate_by_email_password(email, password, subdomain)
    |> case do
      {:error, "Cannot find workspace"} ->
        # TODO: maybe change the error message to the default forbidden message
        ApiGatewayWeb.Gql.Utils.Errors.forbidden_error("Workspace unavailable")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Incorrect email/password combination.")

      {:ok, user} ->
        {:ok, user}
    end
  end

  def logout_user(_, _, %{context: %{current_subdomain: subdomain, current_user: user}})
      when is_nil(user) or is_nil(subdomain) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def logout_user(_, _, _) do
    {:ok, %{ok: true}}
  end
end
