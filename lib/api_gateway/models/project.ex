defmodule ApiGateway.Models.Project do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

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
    belongs_to :owner, ApiGateway.Models.Team, foreign_key: :team_id
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

  ####################
  # Query helpers #
  ####################
  def maybe_title_contains_filter(query, field \\ "")

  def maybe_title_contains_filter(query, field) when is_binary(field) do
    query |> Ecto.Query.where([p], like(p.title, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_title_contains_filter(query, _) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_title_contains_filter(filters[:title_contains])
  end

  ####################
  # Queries #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will raise"
  def get_project(project_id), do: Repo.get(ApiGateway.Models.Project, project_id)

  def get_projects(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Project |> add_query_filters(filters) |> Repo.all()
  end
end
