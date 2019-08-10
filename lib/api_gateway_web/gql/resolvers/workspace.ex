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

  ####################
  # Other resolvers #
  ####################
  def check_workspace_subdomain_available(_, %{input: %{subdomain: subdomain}}, _) do
    is_available? =
      subdomain
      |> ApiGateway.Models.Workspace.get_workspace_by_subdomain()
      |> is_nil()

    # TODO: check weather subdomain is in protected subdomain list
    {:ok, is_available?}
  end
end
