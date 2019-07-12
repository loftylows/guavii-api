defmodule ApiGateway.Models.Project do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "projects" do
    field :title, :string
    field :description, :string
    field :privacy_policy, :string
    field :project_type, :string
    field :status, :string

    has_one :board, ApiGateway.Models.KanbanBoard
    has_one :list, ApiGateway.Models.ProjectTodoList
    has_many :documents, ApiGateway.Models.Document
    belongs_to :workspace, ApiGateway.Models.Workspace
    belongs_to :team, ApiGateway.Models.Team
    belongs_to :created_by, ApiGateway.Models.User

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :workspace_id
  ]
  @required_fields_create [
    :title,
    :workspace_id
  ]

  @project_type [
    "BOARD",
    "LIST"
  ]
  @project_status [
    "ACTIVE",
    "ARCHIVED"
  ]
  @project_privacy_policy [
    "PUBLIC",
    "PRIVATE"
  ]

  def get_project_status do
    @project_status
  end

  def get_project_privacy_policy do
    @project_privacy_policy
  end

  def changeset_create(%ApiGateway.Models.Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(%ApiGateway.Models.Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, @permitted_fields)
  end
end
