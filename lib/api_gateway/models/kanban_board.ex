defmodule ApiGateway.Models.KanbanBoard do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_boards" do
    has_many :lanes, ApiGateway.Models.KanbanLane
    has_many :labels, ApiGateway.Models.KanbanLabel
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :project_id
  ]
  @required_fields_create [
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanBoard{} = kanban_board, attrs \\ %{}) do
    kanban_board
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanBoard{} = kanban_board, attrs \\ %{}) do
    kanban_board
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:project_id)
  end
end
