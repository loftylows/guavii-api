defmodule ApiGateway.Models.ProjectTodoList do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "project_todo_lists" do
    field :title, :string

    has_many :lists, ApiGateway.Models.SubList

    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :project_id
  ]
  @required_fields_create [
    :title,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_id)
  end
end
