defmodule ApiGatewayWeb.Gql.Resolvers.ProjectTodo do
  alias ApiGateway.Models.ProjectTodo
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_project_todo(_, %{where: %{id: project_todo_id}}, _) do
    {:ok, ProjectTodo.get_project_todo(project_todo_id)}
  end

  def get_project_todos(_, %{where: filters}, _) do
    {:ok, ProjectTodo.get_project_todos(filters)}
  end

  def get_project_todos(_, _, _) do
    {:ok, ProjectTodo.get_project_todos()}
  end

  def create_project_todo(_, %{data: data}, _) do
    case ProjectTodo.create_project_todo(data) do
      {:ok, project_todo} ->
        {:ok, project_todo}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "ProjectTodo input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("ProjectTodo input error")
    end
  end

  def update_project_todo(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case ProjectTodo.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      {:ok, project_todo} ->
        payload = %{
          project_todo: project_todo,
          just_normalized: false
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, normalized_items}, {:ok, project_todo}} ->
        payload = %{
          project_todo: project_todo,
          just_normalized: true,
          normalized_project_todos: normalized_items
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("ProjectTodo not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("ProjectTodo input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodo not found")

      {:error, _} ->
        Errors.user_input_error("ProjectTodo input error")
    end
  end

  def update_project_todo(_, %{data: data, where: %{id: id}}, _) do
    case ProjectTodo.update_project_todo(%{id: id, data: data}) do
      {:ok, project_todo} ->
        payload = %{
          project_todo: project_todo,
          just_normalized: false
        }

        {:ok, payload}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("ProjectTodo input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodo not found")

      {:error, _} ->
        Errors.user_input_error("ProjectTodo input error")
    end
  end

  def delete_project_todo(_, %{where: %{id: id}}, _) do
    case ProjectTodo.delete_project_todo(id) do
      {:ok, project_todo} ->
        {:ok, project_todo}

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodo not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
