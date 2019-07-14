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

    many_to_many :members, ApiGateway.Models.User, join_through: "projects_members"
    has_one :board, ApiGateway.Models.KanbanBoard
    has_one :list, ApiGateway.Models.ProjectTodoList
    has_many :documents, ApiGateway.Models.Document
    belongs_to :workspace, ApiGateway.Models.Workspace
    belongs_to :team, ApiGateway.Models.Team
    belongs_to :created_by, ApiGateway.Models.User, foreign_key: :created_by_id

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :privacy_policy,
    :project_type,
    :status,
    :workspace_id,
    :team_id,
    :created_by_id
  ]
  @required_fields_create [
    :title,
    :project_type,
    :workspace_id,
    :team_id,
    :created_by_id
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

  @project_privacy_policy_default "PRIVATE"

  def get_project_status do
    @project_status
  end

  def get_project_privacy_policy do
    @project_privacy_policy
  end

  def get_project_privacy_policy_default do
    @project_privacy_policy_default
  end

  def get_project_type do
    @project_type
  end

  def changeset_create(%ApiGateway.Models.Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:privacy_policy, get_project_privacy_policy())
    |> validate_inclusion(:project_type, get_project_type())
    |> validate_inclusion(:status, get_project_status())
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:created_by_id)
  end

  def changeset_update(%ApiGateway.Models.Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, @permitted_fields)
    |> validate_inclusion(:privacy_policy, get_project_privacy_policy())
    |> validate_inclusion(:project_type, get_project_type())
    |> validate_inclusion(:status, get_project_status())
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:created_by_id)
  end
end
