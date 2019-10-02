defmodule ApiGateway.Models.Workspace do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.InternalSubdomain
  alias ApiGateway.Models.ArchivedWorkspaceSubdomain
  alias ApiGateway.Models.Account.User
  alias __MODULE__

  schema "workspaces" do
    field :title, :string
    field :workspace_subdomain, :string
    field :description, :string
    field :member_cap, :integer, read_after_writes: true
    field :storage_cap, :integer, read_after_writes: true

    has_many :members, ApiGateway.Models.Account.User
    has_many :teams, ApiGateway.Models.Team
    has_many :archived_workspace_subdomains, ApiGateway.Models.ArchivedWorkspaceSubdomain
    has_many :workspace_invitations, ApiGateway.Models.WorkspaceInvitation

    timestamps()
  end

  @permitted_fields [
    :title,
    :workspace_subdomain,
    :description,
    :storage_cap
  ]
  @required_fields_create [
    :title,
    :workspace_subdomain
  ]

  @max_member_count 5_000

  def get_workspace_roles do
    [
      "OWNER",
      "ADMIN",
      "MEMBER"
    ]
  end

  def get_assignable_workspace_roles do
    [
      "ADMIN",
      "MEMBER"
    ]
  end

  def get_workspace_roles_map do
    %{
      owner: "OWNER",
      admin: "ADMIN",
      member: "MEMBER"
    }
  end

  def get_default_workspace_role, do: get_workspace_roles_map().member

  @spec get_workspace_max_member_count :: 5000
  def get_workspace_max_member_count, do: @max_member_count

  ####################
  # Changeset funcs #
  ####################
  def changeset_create(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_format(:workspace_subdomain, Utils.Regex.get_subdomain_regex())
    |> validate_number(:storage_cap, greater_than: 0)
    |> validate_number(:member_cap, greater_than: 0)
    |> unique_constraint(:workspace_subdomain)
  end

  def changeset_update(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_format(:workspace_subdomain, Utils.Regex.get_subdomain_regex())
    |> validate_number(:storage_cap, greater_than: 0)
    |> validate_number(:member_cap, greater_than: 0)
    |> unique_constraint(:workspace_subdomain)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_subdomain_in_filter(query, list \\ [])

  def maybe_subdomain_in_filter(query, list) when is_list(list) and length(list) > 0 do
    query |> Ecto.Query.where([p], p.workspace_subdomain in ^list)
  end

  def maybe_subdomain_in_filter(query, _) do
    query
  end

  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_subdomain_in_filter(filters[:workspace_subdomain_in])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will raise"
  def get_workspace(workspace_id), do: Repo.get(Workspace, workspace_id)

  @type get_workspace_by_subdomain_opts :: [include_archived_matches: boolean]
  @spec get_workspace_by_subdomain(String.t(), get_workspace_by_subdomain_opts) ::
          Workspace.t() | nil
  def get_workspace_by_subdomain(subdomain, opts \\ []) do
    Keyword.get(opts, :include_archived_matches, false)
    |> case do
      bool when not is_boolean(bool) ->
        nil

      false ->
        Workspace
        |> Repo.get_by(workspace_subdomain: subdomain)

      true ->
        Workspace
        |> Repo.get_by(workspace_subdomain: subdomain)
        |> case do
          %Workspace{} = workspace ->
            workspace

          nil ->
            ArchivedWorkspaceSubdomain.get_archived_workspace_subdomain_by_subdomain(subdomain)
            |> case do
              nil ->
                nil

              archived_subdomain ->
                get_workspace(archived_subdomain.workspace_id)
            end
        end
    end
  end

  def get_workspaces(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Workspace |> add_query_filters(filters) |> Repo.all()
  end

  def create_workspace(%{subdomain: subdomain} = data) when is_binary(subdomain) do
    internal_subdomain = InternalSubdomain.get_internal_subdomain_by_subdomain(subdomain)

    archived_subdomain =
      ArchivedWorkspaceSubdomain.get_archived_workspace_subdomain_by_subdomain(subdomain)

    case {internal_subdomain, archived_subdomain} do
      {nil, nil} ->
        %ApiGateway.Models.Workspace{}
        |> changeset_create(Map.put(data, :workspace_subdomain, subdomain))
        |> Repo.insert()

      _ ->
        {:error, "Subdomain taken"}
    end
  end

  def update_workspace(%{id: id, data: data}) do
    case get_workspace(id) do
      nil ->
        {:error, "Not found"}

      workspace ->
        changeset =
          workspace
          |> changeset_update(data)

        case Ecto.Changeset.get_change(changeset, :workspace_subdomain) do
          nil ->
            Repo.update(changeset)

          subdomain ->
            case check_subdomain_taken(subdomain) do
              false ->
                ArchivedWorkspaceSubdomain.create_archived_workspace_subdomain(%{
                  subdomain: workspace.workspace_subdomain,
                  workspace_id: workspace.id
                })

                Repo.update(changeset)

              true ->
                {:error, "Subdomain taken"}
            end
        end
    end
  end

  def update_workspace(%{workspace_subdomain: subdomain, data: data}) do
    case get_workspace_by_subdomain(subdomain) do
      nil ->
        {:error, "Not found"}

      workspace ->
        changeset =
          workspace
          |> changeset_update(data)

        case Ecto.Changeset.get_change(changeset, :workspace_subdomain) do
          nil ->
            Repo.update(changeset)

          subdomain ->
            case check_subdomain_taken(subdomain) do
              false ->
                ArchivedWorkspaceSubdomain.create_archived_workspace_subdomain(%{
                  subdomain: workspace.workspace_subdomain,
                  workspace_id: workspace.id
                })

                Repo.update(changeset)

              true ->
                {:error, "Subdomain taken"}
            end
        end
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_workspace(id) do
    case Repo.get(ApiGateway.Models.Workspace, id) do
      nil ->
        {:error, "Not found"}

      workspace ->
        Repo.delete(workspace)
    end
  end

  def delete_workspace_by_subdomain(subdomain) do
    case Repo.get_by(ApiGateway.Models.Workspace, workspace_subdomain: subdomain) do
      nil ->
        {:error, "Not found"}

      workspace ->
        Repo.delete(workspace)
    end
  end

  def check_subdomain_taken(subdomain) do
    internal = InternalSubdomain.get_internal_subdomain_by_subdomain(subdomain)

    archived = ArchivedWorkspaceSubdomain.get_archived_workspace_subdomain_by_subdomain(subdomain)

    if internal || archived, do: true, else: false
  end

  @spec get_current_workspace_member_count(String.t()) :: integer()
  def get_current_workspace_member_count(workspace_id) do
    User
    |> Ecto.Query.where([user], user.workspace_id == ^workspace_id)
    |> Ecto.Query.select([user], count(user.id))
    |> Repo.one!()
  end

  @spec get_current_active_workspace_member_count(String.t()) :: integer()
  def get_current_active_workspace_member_count(workspace_id) do
    active_status = User.get_active_billing_status()

    User
    |> Ecto.Query.where([user], user.workspace_id == ^workspace_id)
    |> Ecto.Query.where([user], user.billing_status == ^active_status)
    |> Ecto.Query.select([user], count(user.id))
    |> Repo.one!()
  end
end
