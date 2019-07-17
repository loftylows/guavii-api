defmodule ApiGatewayWeb.Gql.Resolvers.Workspace do
  def get_workspace(_, %{where: %{id: workspace_id}}, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspace(workspace_id)}
  end

  def get_workspaces(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspaces(filters)}
  end

  def get_workspaces(_, _, _) do
    {:ok, ApiGateway.Models.Workspace.get_workspaces()}
  end
end
