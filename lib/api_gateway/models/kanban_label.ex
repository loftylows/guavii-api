defmodule ApiGateway.Models.KanbanLabel do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_labels" do
    field :title, :string
    field :color, :string

    belongs_to :kanban_board, ApiGateway.Models.KanbanBoard

    timestamps()
  end

  @permitted_fields [
    :title,
    :color,
    :kanban_board_id
  ]
  @required_fields_create [
    :title,
    :color,
    :kanban_board_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanLabel{} = kanban_label, attrs \\ %{}) do
    kanban_label
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_board_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanLabel{} = kanban_label, attrs \\ %{}) do
    kanban_label
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_board_id)
  end
end
