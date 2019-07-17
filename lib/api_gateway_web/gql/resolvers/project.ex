defmodule ApiGatewayWeb.Gql.Resolvers.Project do
  def get_project(_, %{where: %{id: project_id}}, _) do
    {:ok, ApiGateway.Models.Project.get_project(project_id)}
  end

  def get_projects(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Project.get_projects(filters)}
  end

  def get_projects(_, _, _) do
    {:ok, ApiGateway.Models.Project.get_projects()}
  end
end
