defmodule ApiGateway.Models.KanbanCardTodoList do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_card_todo_lists" do
    field :title, :string

    has_many :todos, ApiGateway.Models.KanbanCardTodo
    belongs_to :kanban_card, ApiGateway.Models.KanbanCard

    timestamps()
  end

  @permitted_fields [
    :title,
    :kanban_card_id
  ]
  @required_fields_create [
    :title,
    :kanban_card_id
  ]

  def changeset_create(
        %ApiGateway.Models.KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_card_id)
  end

  def changeset_update(
        %ApiGateway.Models.KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_card_id)
  end
end
