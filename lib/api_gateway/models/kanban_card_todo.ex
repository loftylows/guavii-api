defmodule ApiGateway.Models.KanbanCardTodo do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_card_todos" do
    field :title, :string
    field :completed, :boolean
    field :due_date, :utc_datetime

    belongs_to :todo_list, ApiGateway.Models.KanbanCardTodoList,
      foreign_key: :kanban_card_todo_list_id

    belongs_to :assigned_to, ApiGateway.Models.User, foreign_key: :user_id
    belongs_to :card, ApiGateway.Models.KanbanCard
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :completed,
    :due_date,
    :kanban_card_todo_list_id,
    :user_id,
    :card_id,
    :project_id
  ]
  @required_fields_create [
    :title,
    :kanban_card_todo_list_id,
    :card_id,
    :project_id
  ]

  def changeset_create(
        %ApiGateway.Models.KanbanCardTodo{} = kanban_card_todo,
        attrs \\ %{}
      ) do
    kanban_card_todo
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:card_id)
    |> foreign_key_constraint(:kanban_card_todo_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(
        %ApiGateway.Models.KanbanCardTodo{} = kanban_card_todo,
        attrs \\ %{}
      ) do
    kanban_card_todo
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:card_id)
    |> foreign_key_constraint(:kanban_card_todo_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end
end
