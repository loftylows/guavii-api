defmodule ApiGateway.Models.KanbanLane do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_lanes" do
    field :title, :string
    field :lane_color, :string

    has_many :cards, ApiGateway.Models.KanbanCard
    belongs_to :kanban_board, ApiGateway.Models.KanbanBoard

    timestamps()
  end

  @permitted_fields [
    :title,
    :lane_color,
    :kanban_board_id
  ]
  @required_fields_create [
    :title,
    :kanban_board_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanLane{} = kanban_lane, attrs \\ %{}) do
    kanban_lane
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_board_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanLane{} = kanban_lane, attrs \\ %{}) do
    kanban_lane
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_board_id)
  end
end
