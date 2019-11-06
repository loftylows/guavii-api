defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCard do
  alias ApiGateway.Models.KanbanCard
  alias ApiGatewayWeb.Gql.Utils.Errors

  def get_kanban_card(_, %{where: %{id: kanban_card_id}}, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_card(kanban_card_id)}
  end

  def get_kanban_cards(
        %{where: filters} = pagination_args,
        _
      ) do
    ApiGateway.Models.KanbanCard.get_kanban_cards_query(filters)
    |> Absinthe.Relay.Connection.from_query(
      &ApiGateway.Repo.all/1,
      Map.drop(pagination_args, [:where])
    )
  end

  def get_kanban_cards(_, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_cards()}
  end

  def create_kanban_card(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def create_kanban_card(_, %{data: data}, %{context: %{current_user: current_user}}) do
    case KanbanCard.create_kanban_card(data, current_user.id) do
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

  def update_kanban_card(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def update_kanban_card(
        _,
        %{
          data: data,
          where: %{id: id},
          list_item_position: %{prev_item_rank: prev, next_item_rank: next}
        },
        %{context: %{current_user: current_user}}
      ) do
    case KanbanCard.update_with_position(
           %{id: id, data: data, prev: prev, next: next},
           current_user.id
         ) do
      {:ok, kanban_card} ->
        payload = %{
          kanban_card: kanban_card,
          just_normalized: false
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, normalized_items}, {:ok, kanban_card}} ->
        payload = %{
          kanban_card: kanban_card,
          just_normalized: true,
          normalized_kanban_cards: normalized_items
        }

        {:ok, payload}

      {{:list_order_normalized, _normalized_list_id, _normalized_items}, {:error, "Not found"}} ->
        Errors.user_input_error("KanbanCard not found")

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("KanbanCard input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("KanbanCard not found")

      {:error, _} ->
        Errors.user_input_error("KanbanCard input error")
    end
  end

  def update_kanban_card(_, %{data: data, where: %{id: id}}, %{
        context: %{current_user: current_user}
      }) do
    case KanbanCard.update_kanban_card(%{id: id, data: data}, current_user.id) do
      {:ok, kanban_card} ->
        payload = %{
          kanban_card: kanban_card,
          just_normalized: false
        }

        {:ok, payload}

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
