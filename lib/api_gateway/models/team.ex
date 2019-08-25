defmodule ApiGateway.Models.Team do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.TeamMember
  alias __MODULE__

  schema "teams" do
    field :title, :string
    field :description, :string

    has_many :members, ApiGateway.Models.TeamMember
    has_many :projects, ApiGateway.Models.Project
    belongs_to :workspace, ApiGateway.Models.Workspace

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

  def changeset_create(%ApiGateway.Models.Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(%Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, workspace_id) when is_nil(workspace_id) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.join(:inner, [team], workspace in ApiGateway.Models.Workspace,
      on: team.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([team, workspace], team)
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
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "team_id must be a valid 'uuid' or an error will raise"
  def get_team(team_id), do: Repo.get(Team, team_id)

  def get_teams(filters \\ %{}) do
    Team
    |> add_query_filters(filters)
    |> Repo.all()
  end

  def create_team(data) when is_map(data) do
    %Team{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def create_team_with_member(data, %{id: user_id, workspace_id: workspace_id})
      when is_map(data) do
    %Team{}
    |> changeset_create(Map.put(data, :workspace_id, workspace_id))
    |> Repo.insert()
    |> case do
      {:error, _} = error ->
        error

      {:ok, team} ->
        roles_map = TeamMember.get_team_member_roles_map()

        %{user_id: user_id, team_id: team.id, role: roles_map.admin}
        |> ApiGateway.Models.TeamMember.create_team_member()
        |> case do
          {:error, _} ->
            delete_team(team.id)

            {:error, :internal_error}

          {:ok, _} ->
            {:ok, team}
        end
    end
  end

  def update_team(%{id: id, data: data}) do
    case get_team(id) do
      nil ->
        {:error, "Not found"}

      team ->
        team
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_team(id) do
    case get_team(id) do
      nil ->
        {:error, "Not found"}

      team ->
        Repo.delete(team)
    end
  end
end
