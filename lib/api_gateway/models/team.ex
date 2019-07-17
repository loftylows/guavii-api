defmodule ApiGateway.Models.Team do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

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

  def changeset_update(%ApiGateway.Models.Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:workspace_id)
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
  @doc "team_id must be a valid 'uuid' or an error will raise"
  def get_team(team_id), do: Repo.get(ApiGateway.Models.Team, team_id)

  def get_teams(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Team |> add_query_filters(filters) |> Repo.all()
  end
end
