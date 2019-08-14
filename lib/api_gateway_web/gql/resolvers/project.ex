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

  def create_project(_, %{data: _}, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def create_project(_, %{data: data}, %{context: %{current_user: user}}) do
    case ApiGateway.Models.Project.create_project(data, user.id) do
      {:ok, project} ->
        {:ok, project}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Project input error",
          errors
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Project input error")
    end
  end

  def update_project(_, %{data: data, where: %{id: id}}, _) do
    case ApiGateway.Models.Project.update_project(%{id: id, data: data}) do
      {:ok, project} ->
        {:ok, project}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Project input error",
          errors
        )

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Project not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Project input error")
    end
  end

  def delete_project(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Project.delete_project(id) do
      {:ok, project} ->
        {:ok, project}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Project not found")
    end
  end
end
