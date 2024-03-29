defmodule ApiGatewayWeb.Gql.Resolvers.Workspace do
  ####################
  # CRUD resolvers #
  ####################
  def get_workspace(_, %{where: %{id: workspace_id}}, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspace(workspace_id)}
  end

  def get_workspace(_, %{where: %{workspace_subdomain: workspace_subdomain}}, _) do
    workspace =
      workspace_subdomain
      |> ApiGateway.Models.Workspace.get_workspace_by_subdomain()

    {:ok, workspace}
  end

  def get_workspaces(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspaces(filters)}
  end

  def get_workspaces(_, _, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspaces()}
  end

  def create_workspace(_, %{data: data}, _) do
    case ApiGateway.Models.Workspace.create_workspace(data) do
      {:ok, workspace} ->
        {:ok, workspace}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "User input error",
          errors
        )

      {:error, "Subdomain taken"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace subdomain taken")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def update_workspace(_, %{data: %{workspace_subdomain: subdomain} = data, where: %{id: id}}, _) do
    case ApiGateway.Models.Workspace.update_workspace(%{id: id, data: data}) do
      {:ok, workspace} ->
        # Send out subscription if workspace subdomain changed
        if subdomain == workspace.workspace_subdomain do
          Absinthe.Subscription.publish(
            ApiGatewayWeb.Endpoint,
            workspace,
            workspace_subdomain_updated: workspace.id
          )
        end

        {:ok, workspace}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace not found")

      {:error, "Subdomain taken"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error(
          "Workspace subdomain is taken or temporarily archived."
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def update_workspace(_, %{data: data, where: %{id: id}}, _) do
    case ApiGateway.Models.Workspace.update_workspace(%{id: id, data: data}) do
      {:ok, workspace} ->
        {:ok, workspace}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace not found")

      {:error, "Subdomain taken"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace subdomain taken")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def update_workspace(_, %{data: data, where: %{workspace_subdomain: subdomain}}, _) do
    case ApiGateway.Models.Workspace.update_workspace(%{
           workspace_subdomain: subdomain,
           data: data
         }) do
      {:ok, workspace} ->
        {:ok, workspace}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("User input error", errors)

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace not found")

      {:error, "Subdomain taken"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace subdomain taken")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User input error")
    end
  end

  def delete_workspace(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Workspace.delete_workspace(id) do
      {:ok, workspace} ->
        {:ok, workspace}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace not found")
    end
  end

  def delete_workspace(_, %{where: %{workspace_subdomain: subdomain}}, _) do
    case ApiGateway.Models.Workspace.delete_workspace_by_subdomain(subdomain) do
      {:ok, workspace} ->
        {:ok, workspace}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Workspace not found")
    end
  end

  def current_active_member_count(%ApiGateway.Models.Workspace{} = workspace, _, _) do
    count = ApiGateway.Models.Workspace.get_current_active_workspace_member_count(workspace.id)

    {:ok, count}
  end

  ####################
  # Other resolvers #
  ####################
  def check_workspace_subdomain_available(_, %{data: %{subdomain: subdomain}}, _) do
    is_available? = ApiGateway.Models.Workspace.check_subdomain_available(subdomain)

    {:ok, is_available?}
  end

  def check_workspace_exists_by_subdomain(_, %{data: %{subdomain: subdomain}}, _) do
    exists? = ApiGateway.Models.Workspace.check_workspace_exists_by_subdomain(subdomain)

    {:ok, exists?}
  end
end
