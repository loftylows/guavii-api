defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCard do
  alias ApiGateway.Models.KanbanCard
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_kanban_card(_, %{where: %{id: kanban_card_id}}, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_card(kanban_card_id)}
  end

  def get_kanban_cards(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_cards(filters)}
  end

  def get_kanban_cards(_, _, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_cards()}
  end

  def create_kanban_card(_, %{data: data}, _) do
    case KanbanCard.create_kanban_card(data) do
      {:ok, kanban_card} ->
        {:ok, kanban_card}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "KanbanCard input error",
          errors
        )

      {:error, _} ->
        Errors.user_input_error("KanbanCard input error")
    end
  end

  def update_kanban_card(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        _
      ) do
    case KanbanCard.update_with_position(%{id: id, data: data, prev: prev, next: next}) do
      # TODO: send out a subscription notification about this list normalization
      {{:list_order_normalized, _normalized_list_id}, {:ok, kanban_card}} ->
        {:ok, kanban_card}

      {{:list_order_normalized, _normalized_list_id}, {:error, "Not found"}} ->
        Errors.user_input_error("KanbanCard not found")

      {:ok, kanban_card} ->
        {:ok, kanban_card}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCard input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCard not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCard input error")
    end
  end

  def update_kanban_card(_, %{data: data, where: %{id: id}}, _) do
    case KanbanCard.update_kanban_card(%{id: id, data: data}) do
      {:ok, kanban_card} ->
        {:ok, kanban_card}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCard input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCard not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCard input error")
    end
  end

  def delete_kanban_card(_, %{where: %{id: id}}, _) do
    case KanbanCard.delete_kanban_card(id) do
      {:ok, kanban_card} ->
        {:ok, kanban_card}

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCard not found")
    end
  end
end
