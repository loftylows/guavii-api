defmodule ApiGateway.Models.Team do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.TeamMember
  alias ApiGateway.Models.Account.User
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
    |> Ecto.Query.where([x], x.workspace_id == ^workspace_id)
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

  def add_team_members(%{id: id, data: %{info_items: info_items}}, %User{} = current_user) do
    case get_team(id) do
      nil ->
        {:error, "Not found"}

      team ->
        users_emails = Enum.map(info_items, fn %{email: email} -> email end)

        User.get_users(%{email_in: users_emails, workspace_id: current_user.workspace_id})
        |> case do
          [] ->
            {:ok, team}

          users ->
            user_ids = Enum.map(users, fn %{id: id} -> id end)

            users_ids_of_already_team_members =
              TeamMember.get_team_members(%{user_id_in: user_ids, team_id: team.id})
              |> Enum.map(fn team_member -> team_member.user_id end)

            users_by_email_map =
              users
              |> Enum.into(%{}, fn user -> {user.email, user} end)

            filtered_info_items =
              info_items
              |> Enum.filter(fn %{email: email} ->
                users_by_email_map[email] &&
                  not (users_by_email_map[email].id in users_ids_of_already_team_members)
              end)

            now =
              DateTime.utc_now()
              |> DateTime.truncate(:second)

            team_members =
              for %{email: email} = info_item <- filtered_info_items do
                role = Map.get(info_item, :team_role, TeamMember.get_default_team_member_role())

                %{
                  role: role,
                  user_id: users_by_email_map[email].id,
                  team_id: team.id,
                  inserted_at: now,
                  updated_at: now
                }
              end

            team_members |> TeamMember.create_team_members()

            {:ok, team}
        end
    end
  end

  def remove_user_from_team(id) when is_binary(id) do
    TeamMember.get_team_member(id)
    |> case do
      nil ->
        {:error, "User input error"}

      team_member ->
        TeamMember.get_team_members(%{team_id: team_member.team_id})
        |> case do
          [] ->
            {:error, "User input error"}

          team_members when is_list(team_members) and length(team_members) == 1 ->
            {:error, "Must be at least one member on a team"}

          team_members ->
            member_roles_map = TeamMember.get_team_member_roles_map()
            admin_role = member_roles_map.admin

            team_member
            |> case do
              %TeamMember{role: ^admin_role} ->
                admin_members =
                  Enum.filter(team_members, fn member -> member.role == member_roles_map.admin end)

                if length(admin_members) == 1 do
                  {:error, "Cannot remove last admin from team"}
                else
                  get_team(team_member.team_id)
                  |> case do
                    nil ->
                      {:error, "User input error"}

                    team ->
                      TeamMember.delete_team_member(id)
                      |> case do
                        {:error, _} ->
                          {:error, "Team member does not exist."}

                        _ ->
                          {:ok, team}
                      end
                  end
                end

              _ ->
                get_team(team_member.team_id)
                |> case do
                  nil ->
                    {:error, "User input error"}

                  team ->
                    TeamMember.delete_team_member(id)
                    |> case do
                      {:error, _} ->
                        {:error, "Team member does not exist."}

                      _ ->
                        {:ok, team}
                    end
                end
            end
        end
    end
  end
end
