defmodule ApiGatewayWeb.Gql.Resolvers.ProjectTodoList do
  alias ApiGateway.Models.ProjectTodoList
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_project_todo_list(_, %{where: %{id: project_todo_list_id}}, _) do
    {:ok, ProjectTodoList.get_project_todo_list(project_todo_list_id)}
  end

  def get_project_todo_lists(_, %{where: filters}, _) do
    {:ok, ProjectTodoList.get_project_todo_lists(filters)}
  end

  def get_project_todo_lists(_, _, _) do
    {:ok, ProjectTodoList.get_project_todo_lists()}
  end

  def create_project_todo_list(_, %{data: data}, _) do
    case ProjectTodoList.create_project_todo_list(data) do
      {:ok, project_todo_list} ->
        {:ok, project_todo_list}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "ProjectTodoList input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("ProjectTodoList input error")
    end
  end

  def update_project_todo_list(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case ProjectTodoList.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      {:ok, project_todo_list} ->
        payload = %{
          project_todo_list: project_todo_list,
          just_normalized: false
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, normalized_items}, {:ok, project_todo_list}} ->
        payload = %{
          project_todo_list: project_todo_list,
          just_normalized: true,
          normalized_project_todo_lists: normalized_items
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("ProjectTodoList not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("ProjectTodoList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodoList not found")

      {:error, _} ->
        Errors.user_input_error("ProjectTodoList input error")
    end
  end

  def update_project_todo_list(_, %{data: data, where: %{id: id}}, _) do
    case ProjectTodoList.update_project_todo_list(%{id: id, data: data}) do
      {:ok, project_todo_list} ->
        payload = %{
          project_todo_list: project_todo_list,
          just_normalized: false
        }

        {:ok, payload}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("ProjectTodoList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodoList not found")

      {:error, _} ->
        Errors.user_input_error("ProjectTodoList input error")
    end
  end

  def delete_project_todo_list(_, %{where: %{id: id}}, _) do
    case ProjectTodoList.delete_project_todo_list(id) do
      {:ok, project_todo_list} ->
        {:ok, project_todo_list}

      {:error, "Not found"} ->
        Errors.user_input_error("ProjectTodoList not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
