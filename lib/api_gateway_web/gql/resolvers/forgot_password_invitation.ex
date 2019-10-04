defmodule ApiGatewayWeb.Gql.Resolvers.ForgotPasswordInvitation do
  alias ApiGateway.Models.Account.User
  alias ApiGateway.Models.ForgotPasswordInvitation

  # this guard makes sure that the user isn't logged in and that they are sending the request from a subdomain
  def send_forgot_password_invitation(_, %{data: %{email: _}}, %{
        context: %{current_subdomain: subdomain, current_user: user}
      })
      when is_map(user) or is_nil(subdomain) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def send_forgot_password_invitation(_, %{data: %{email: email}}, %{
        context: %{current_subdomain: subdomain}
      }) do
    case User.get_user_by_email_and_subdomain(email, subdomain) do
      nil ->
        {:ok, %{ok: true}}

      user ->
        {:ok, token} =
          ForgotPasswordInvitation.create_or_update_forgot_password_invitation(%{user_id: user.id})

        ApiGateway.Email.Transactional.send_forgot_password_email(
          email,
          user.id,
          subdomain,
          token
        )

        {:ok, %{ok: true}}
    end
  end

  # this guard makes sure that the user isn't logged in and that they are sending the request from a subdomain
  def reset_password_from_forgot_password_invite(_, _, %{
        context: %{current_subdomain: subdomain, current_user: user}
      })
      when is_map(user) or is_nil(subdomain) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  # TODO: refactor this resolver. The pattern matching is sloppy
  def reset_password_from_forgot_password_invite(
        _,
        %{data: %{user_id: user_id, token: token, password: password}},
        _
      ) do
    ForgotPasswordInvitation.reset_password_from_forgot_password_invite(password, user_id, token)
    |> case do
      {:error, :invitation, "Internal error"} ->
        ApiGatewayWeb.Gql.Utils.Errors.internal_error()

      {:error, :invitation, reason} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error(reason)

      {:error, :user, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, :user, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.internal_error()

      {:ok, user} ->
        token = ApiGatewayWeb.Session.create_token(user.id)

        {:ok, %{user: user, token: token}}
    end
  end
end
