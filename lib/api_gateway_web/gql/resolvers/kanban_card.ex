defmodule ApiGatewayWeb.Gql.Resolvers.KanbanCard do
  def get_kanban_card(_, %{where: %{id: kanban_card_id}}, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_card(kanban_card_id)}
  end

  def get_kanban_cards(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_cards(filters)}
  end

  def get_kanban_cards(_, _, _) do
    {:ok, ApiGateway.Models.KanbanCard.get_kanban_cards()}
  end
end
