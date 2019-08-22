defmodule ApiGateway.Models.KanbanCardActiveLabels do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase

  @primary_key false
  schema "kanban_card_active_labels" do
    belongs_to :kanban_card, ApiGateway.Models.KanbanCard
    belongs_to :kanban_label, ApiGateway.Models.KanbanLabel

    timestamps()
  end
end
