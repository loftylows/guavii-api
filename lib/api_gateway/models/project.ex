defmodule ApiGateway.Models.Project do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.Account.User

  schema "projects" do
    field :title, :string
    field :description, :string
    field :privacy_policy, :string, read_after_writes: true
    field :project_type, :string
    field :status, :string, read_after_writes: true

    many_to_many :members, ApiGateway.Models.Account.User, join_through: "projects_members"
    has_one :kanban_board, ApiGateway.Models.KanbanBoard
    has_one :lists_board, ApiGateway.Models.ProjectListsBoard
    has_many :documents, ApiGateway.Models.Document
    belongs_to :workspace, ApiGateway.Models.Workspace
    belongs_to :owner, ApiGateway.Models.Team, foreign_key: :team_id
    belongs_to :created_by, ApiGateway.Models.Account.User, foreign_key: :created_by_id

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
  @required_fields [
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

  @project_privacy_policy_default "PUBLIC"

  @project_status_default "ACTIVE"

  def get_project_status do
    @project_status
  end

  def get_project_privacy_policy do
    @project_privacy_policy
  end

  def get_project_privacy_policy_default do
    @project_privacy_policy_default
  end

  def get_project_status_default do
    @project_status_default
  end

  def get_project_type do
    @project_type
  end

  def changeset(%ApiGateway.Models.Project{} = project, attrs \\ %{}) do
    project
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
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
  def maybe_project_type_filter(query, project_type \\ nil)

  def maybe_project_type_filter(query, project_type) when is_nil(project_type) do
    query
  end

  def maybe_project_type_filter(query, project_type) do
    query |> Ecto.Query.where([project], project.project_type == ^project_type)
  end

  def maybe_project_status_filter(query, nil) do
    query
  end

  def maybe_project_status_filter(query, status) do
    query |> Ecto.Query.where([project], project.status == ^status)
  end

  def maybe_project_privacy_policy_filter(query, nil) do
    query
  end

  def maybe_project_privacy_policy_filter(query, privacy_policy) do
    query
    |> Ecto.Query.where([project], project.privacy_policy == ^privacy_policy)
  end

  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, workspace_id) when is_nil(workspace_id) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.distinct(true)
    |> Ecto.Query.join(:inner, [project], workspace in ApiGateway.Models.Workspace,
      on: project.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([project, workspace], project)
  end

  @doc "owner_id must be a valid 'uuid' or an error will be raised"
  def maybe_owner_id_assoc_filter(query, owner_id) when is_nil(owner_id) do
    query
  end

  def maybe_owner_id_assoc_filter(query, owner_id) do
    query
    |> Ecto.Query.distinct(true)
    |> Ecto.Query.join(:inner, [project], team in ApiGateway.Models.Team,
      on: project.team_id == ^owner_id
    )
    |> Ecto.Query.select([project, team], project)
  end

  @doc "created_by_id must be a valid 'uuid' or an error will be raised"
  def maybe_created_by_id_assoc_filter(query, created_by_id) when is_nil(created_by_id) do
    query
  end

  def maybe_created_by_id_assoc_filter(query, created_by_id) do
    query
    |> Ecto.Query.distinct(true)
    |> Ecto.Query.join(:inner, [project], user in ApiGateway.Models.Account.User,
      on: project.user_id == ^created_by_id
    )
    |> Ecto.Query.select([project, user], project)
  end

  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> maybe_project_type_filter(filters[:project_type])
    |> maybe_project_status_filter(filters[:status])
    |> maybe_project_privacy_policy_filter(filters[:privacy_policy])
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
    |> maybe_owner_id_assoc_filter(filters[:owner_id])
    |> maybe_created_by_id_assoc_filter(filters[:created_by_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will raise"
  def get_project(project_id) do
    ApiGateway.Models.Project
    |> Ecto.Query.preload(:kanban_board)
    |> Ecto.Query.preload(:lists_board)
    |> Repo.get(project_id)
  end

  def get_projects(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Project
    |> Ecto.Query.preload(:kanban_board)
    |> Ecto.Query.preload(:lists_board)
    |> add_query_filters(filters)
    |> Repo.all()
  end

  def create_project(%{project_type: "BOARD"} = data, %User{} = user) do
    full_data =
      data
      |> Map.put(:created_by_id, user.id)
      |> Map.put(:workspace_id, user.workspace_id)

    project_result =
      %ApiGateway.Models.Project{}
      |> changeset(full_data)
      |> Repo.insert()

    case project_result do
      {:ok, project} ->
        case ApiGateway.Models.KanbanBoard.create_kanban_board(%{project_id: project.id}) do
          {:ok, kanban_board} ->
            {:ok, Map.put(project, :kanban_board, kanban_board)}

          {:error, _} = errors ->
            ApiGateway.Models.Project.delete_project(project.id)

            errors
        end

      {:error, _} = result ->
        result
    end
  end

  def create_project(%{project_type: "LIST"} = data, %User{} = user) do
    full_data =
      data
      |> Map.put(:created_by_id, user.id)
      |> Map.put(:workspace_id, user.workspace_id)

    project_result =
      %ApiGateway.Models.Project{}
      |> changeset(full_data)
      |> Repo.insert()

    case project_result do
      {:ok, project} ->
        case ApiGateway.Models.ProjectListsBoard.create_project_lists_board(%{
               project_id: project.id
             }) do
          {:ok, lists_board} ->
            {:ok, Map.put(project, :lists_board, lists_board)}

          {:error, _} = errors ->
            ApiGateway.Models.Project.delete_project(project.id)

            errors
        end

      {:error, _} = result ->
        result
    end
  end

  def update_project(%{id: id, data: data}) do
    case get_project(id) do
      nil ->
        {:error, "Not found"}

      project ->
        project
        |> changeset(data)
        |> Repo.update()
        |> case do
          {:error, _} = error ->
            error

          {:ok, project} ->
            full_project =
              project
              |> Repo.preload(:kanban_board)

            {:ok, full_project}
        end
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_project(id) do
    case get_project(id) do
      nil ->
        {:error, "Not found"}

      project ->
        Repo.delete(project)
    end
  end
end
