defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCardTodo do
  alias ApiGateway.Models.KanbanCardTodo
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_kanban_card_todo(_, %{where: %{id: kanban_card_todo_id}}, _) do
    {:ok, KanbanCardTodo.get_kanban_card_todo(kanban_card_todo_id)}
  end

  def get_kanban_card_todos(_, %{where: filters}, _) do
    {:ok, KanbanCardTodo.get_kanban_card_todos(filters)}
  end

  def get_kanban_card_todos(_, _, _) do
    {:ok, KanbanCardTodo.get_kanban_card_todos()}
  end

  def create_kanban_card_todo(_, %{data: data}, _) do
    case KanbanCardTodo.create_kanban_card_todo(data) do
      {:ok, kanban_card_todo} ->
        {:ok, kanban_card_todo}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanCardTodo input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodo input error")
    end
  end

  def update_kanban_card_todo(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case KanbanCardTodo.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id}, {:ok, kanban_card_todo}} ->
        {:ok, kanban_card_todo}

      {{:list_order_normalized, _normalized_list_id}, {:error, "Not found"}} ->
        Errors.user_input_error("KanbanCardTodo not found")

      {:ok, kanban_card_todo} ->
        {:ok, kanban_card_todo}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCardTodo input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodo not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodo input error")
    end
  end

  def update_kanban_card_todo(_, %{data: data, where: %{id: id}}, _) do
    case KanbanCardTodo.update_kanban_card_todo(%{id: id, data: data}) do
      {:ok, kanban_card_todo} ->
        {:ok, kanban_card_todo}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCardTodo input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodo not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCardTodo input error")
    end
  end

  def delete_kanban_card_todo(_, %{where: %{id: id}}, _) do
    case KanbanCardTodo.delete_kanban_card_todo(id) do
      {:ok, kanban_card_todo} ->
        {:ok, kanban_card_todo}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardTodo not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
