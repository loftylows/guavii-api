defmodule ApiGateway.Models.KanbanCard do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_lanes" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date_range, ApiGateway.CustomEctoTypes.EctoDateRange

    has_many :todo_lists, ApiGateway.Models.KanbanCardTodoList
    has_many :comments, ApiGateway.Models.KanbanCardComment

    many_to_many :activeLabels, ApiGateway.Models.KanbanLabel,
      join_through: "kanban_cards_active_labels"

    belongs_to :kanban_lane, ApiGateway.Models.KanbanLane
    belongs_to :project, ApiGateway.Models.Project
    belongs_to :assignedTo, ApiGateway.Models.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :completed,
    :attachments,
    :due_date_range,
    :kanban_lane_id,
    :project_id,
    :user_id
  ]
  @required_fields_create [
    :title,
    :kanban_lane_id,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end
end
