defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCardComment do
  alias ApiGatewayWeb.Gql.Utils.Errors
  alias ApiGateway.Models

  def get_kanban_card_comment(_, %{where: %{id: kanban_card_comment_id}}, _) do
    {:ok, Models.KanbanCardComment.get_kanban_card_comment(kanban_card_comment_id)}
  end

  def get_kanban_card_comments(_, %{where: filters}, _) do
    {:ok, Models.KanbanCardComment.get_kanban_card_comments(filters)}
  end

  def get_kanban_card_comments(_, _, _) do
    {:ok, Models.KanbanCardComment.get_kanban_card_comments()}
  end

  def create_kanban_card_comment(_, %{data: data}, _) do
    case Models.KanbanCardComment.create_kanban_card_comment(data) do
      {:ok, kanban_card_comment} ->
        {:ok, kanban_card_comment}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanCardComment input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanCardComment input error")
    end
  end

  def update_kanban_card_comment(_, %{data: data, where: %{id: id}}, _) do
    case Models.KanbanCardComment.update_kanban_card_comment(%{id: id, data: data}) do
      {:ok, kanban_card_comment} ->
        {:ok, kanban_card_comment}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCardComment input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardComment not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCardComment input error")
    end
  end

  def delete_kanban_card_comment(_, %{where: %{id: id}}, _) do
    case Models.KanbanCardComment.delete_kanban_card_comment(id) do
      {:ok, kanban_card_comment} ->
        {:ok, kanban_card_comment}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCardComment not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
