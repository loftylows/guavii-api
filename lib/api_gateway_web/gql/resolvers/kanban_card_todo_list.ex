defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCardTodoList do
  alias ApiGateway.Models.KanbanCardTodoList
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_kanban_card_todo_list(_, %{where: %{id: kanban_card_todo_list_id}}, _) do
    {:ok, KanbanCardTodoList.get_kanban_card_todo_list(kanban_card_todo_list_id)}
  end

  def get_kanban_card_todo_lists(_, %{where: filters}, _) do
    {:ok, KanbanCardTodoList.get_kanban_card_todo_lists(filters)}
  end

  def get_kanban_card_todo_lists(_, _, _) do
    {:ok, KanbanCardTodoList.get_kanban_card_todo_lists()}
  end

  def create_kanban_card_todo_list(_, %{data: data}, _) do
    case KanbanCardTodoList.create_kanban_card_todo_list(data) do
      {:ok, kanban_card_todo_list} ->
        {:ok, kanban_card_todo_list}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanCardTodoList input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodoList input error")
    end
  end

  def update_kanban_card_todo_list(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case KanbanCardTodoList.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      {:ok, kanban_card_todo_list} ->
        payload = %{
          kanban_card_todo_list: kanban_card_todo_list,
          just_normalized: false
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, normalized_items},
       {:ok, kanban_card_todo_list}} ->
        payload = %{
          kanban_card_todo_list: kanban_card_todo_list,
          just_normalized: true,
          normalized_kanban_card_todo_lists: normalized_items
        }

        {:ok, payload}

      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("KanbanCardTodoList not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCardTodoList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodoList not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodoList input error")
    end
  end

  def update_kanban_card_todo_list(_, %{data: data, where: %{id: id}}, _) do
    case KanbanCardTodoList.update_kanban_card_todo_list(%{id: id, data: data}) do
      {:ok, kanban_card_todo_list} ->
        payload = %{
          kanban_card_todo_list: kanban_card_todo_list,
          just_normalized: false
        }

        {:ok, payload}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCardTodoList input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodoList not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodoList input error")
    end
  end

  def delete_kanban_card_todo_list(_, %{where: %{id: id}}, _) do
    case KanbanCardTodoList.delete_kanban_card_todo_list(id) do
      {:ok, kanban_card_todo_list} ->
        {:ok, kanban_card_todo_list}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodoList not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
