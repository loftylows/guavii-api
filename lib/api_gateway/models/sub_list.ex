defmodule ApiGateway.Models.SubList do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "sub_lists" do
    field :title, :string

    has_many :lists_items, ApiGateway.Models.SubListItem

    belongs_to :project_todo_list, ApiGateway.Models.ProjectTodoList

    timestamps()
  end

  @permitted_fields [
    :title,
    :project_todo_list_id
  ]
  @required_fields_create [
    :title,
    :project_todo_list_id
  ]

  def changeset_create(%ApiGateway.Models.SubList{} = sub_list, attrs \\ %{}) do
    sub_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_todo_list_id)
  end

  def changeset_update(%ApiGateway.Models.SubList{} = sub_list, attrs \\ %{}) do
    sub_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_todo_list_id)
  end
end
