defmodule ApiGateway.Models.TeamMember do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias __MODULE__

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

  @team_member_roles_map %{
    member: "MEMBER",
    admin: "ADMIN"
  }

  def get_team_member_roles do
    @team_member_roles
  end

  def get_team_member_roles_map do
    @team_member_roles_map
  end

  def get_default_team_member_role do
    %{member: member_role} = get_team_member_roles_map()

    member_role
  end

  def changeset_create(%TeamMember{} = team_member, attrs \\ %{}) do
    team_member
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:role, get_team_member_roles())
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%TeamMember{} = team_member, attrs \\ %{}) do
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
    |> Ecto.Query.where([x], x.team_id == ^team_id)
  end

  @doc "user_ids must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_in_assoc_filter(query, nil) do
    query
  end

  def maybe_user_id_in_assoc_filter(query, user_ids) do
    query
    |> Ecto.Query.where([x], x.user_id in ^user_ids)
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, nil) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.where([x], x.user_id == ^user_id)
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
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_user_id_in_assoc_filter(filters[:user_id_in])
    |> maybe_role_filter(filters[:role])
    |> maybe_team_id_assoc_filter(filters[:team_id])
    |> maybe_user_id_assoc_filter(filters[:user_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_team_member(id), do: Repo.get(TeamMember, id)

  def get_team_members(filters \\ %{}) do
    IO.inspect(filters)

    TeamMember |> add_query_filters(filters) |> Repo.all()
  end

  def create_team_member(data) when is_map(data) do
    %TeamMember{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def create_team_members(team_id, data_items) when is_list(data_items) and is_binary(team_id) do
    IO.inspect(data_items)

    TeamMember
    |> Repo.insert_all(data_items)

    user_ids = Enum.map(data_items, fn data -> data.user_id end)

    TeamMember.get_team_members(%{user_id_in: user_ids, team_id: team_id})
  end

  def update_team_member(%{id: id, data: data}) do
    case get_team_member(id) do
      nil ->
        {:error, "Not found"}

      team_member ->
        team_member
        |> changeset_update(data)
        |> _update_team_member_helper(team_member)
    end
  end

  defp _update_team_member_helper(
         %Ecto.Changeset{valid?: true, changes: %{role: role}} = changeset,
         %TeamMember{} = team_member
       ) do
    member_roles = get_team_member_roles_map()
    admin_role = member_roles.admin

    case role != admin_role and team_member.role == admin_role do
      false ->
        changeset
        |> Repo.update()

      true ->
        TeamMember.get_team_members(%{team_id: team_member.team_id})
        |> case do
          [] ->
            {:error, "User input error"}

          team_members when is_list(team_members) and length(team_members) == 1 ->
            {:error, "Must be at least one admin on a team"}

          team_members ->
            admin_members = Enum.filter(team_members, fn member -> member.role == admin_role end)

            if length(admin_members) == 1 do
              {:error, "Must be at least one admin on a team"}
            else
              changeset
              |> Repo.update()
            end
        end
    end
  end

  defp _update_team_member_helper(%Ecto.Changeset{} = changeset, %TeamMember{}) do
    changeset
    |> Repo.update()
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
