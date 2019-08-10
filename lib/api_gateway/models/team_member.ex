defmodule ApiGateway.Models.TeamMember do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "team_members" do
    field :role, :string

    belongs_to :user, ApiGateway.Models.Account.User
    belongs_to :team, ApiGateway.Models.Team

    timestamps()
  end

  @permitted_fields [
    :role,
    :team_id,
    :user_id
  ]
  @required_fields_create [
    :role,
    :team_id,
    :user_id
  ]

  @team_member_roles [
    "MEMBER",
    "ADMIN"
  ]

  def get_team_member_roles do
    @team_member_roles
  end

  def changeset_create(%ApiGateway.Models.TeamMember{} = team_member, attrs \\ %{}) do
    team_member
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:role, get_team_member_roles())
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.TeamMember{} = team_member, attrs \\ %{}) do
    team_member
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:role, get_team_member_roles())
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_role_filter(query, role \\ nil)

  def maybe_role_filter(query, role) when is_nil(role) do
    query
  end

  def maybe_role_filter(query, role) do
    query |> Ecto.Query.where([p], p.role == ^role)
  end

  @doc "team_id must be a valid 'uuid' or an error will be raised"
  def maybe_team_id_assoc_filter(query, team_id) when is_nil(team_id) do
    query
  end

  def maybe_team_id_assoc_filter(query, team_id) do
    query
    |> Ecto.Query.join(:inner, [team_member], team in ApiGateway.Models.Team,
      on: team_member.team_id == ^team_id
    )
    |> Ecto.Query.select([team_member, team], team_member)
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, user_id) when is_nil(user_id) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.join(:inner, [team_member], user in ApiGateway.Models.Account.User,
      on: team_member.user_id == ^user_id
    )
    |> Ecto.Query.select([team_member, user], team_member)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_role_filter(filters[:role])
    |> maybe_team_id_assoc_filter(filters[:team_id])
    |> maybe_user_id_assoc_filter(filters[:user_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_team_member(id), do: Repo.get(ApiGateway.Models.TeamMember, id)

  def get_team_members(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.TeamMember |> add_query_filters(filters) |> Repo.all()
  end

  def create_team_member(data) when is_map(data) do
    %ApiGateway.Models.TeamMember{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_team_member(%{id: id, data: data}) do
    case get_team_member(id) do
      nil ->
        {:error, "Not found"}

      team_member ->
        team_member
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_team_member(id) do
    case Repo.get(ApiGateway.Models.TeamMember, id) do
      nil ->
        {:error, "Not found"}

      team_member ->
        Repo.delete(team_member)
    end
  end
end
