defmodule ApiGateway.Models.Workspace do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.InternalSubdomain
  alias ApiGateway.Models.ArchivedWorkspaceSubdomain

  schema "workspaces" do
    field :title, :string
    field :workspace_subdomain, :string
    field :description, :string
    field :storage_cap, :integer, read_after_writes: true

    has_many :members, ApiGateway.Models.Account.User
    has_many :teams, ApiGateway.Models.Team
    has_many :archived_workspace_subdomains, ApiGateway.Models.ArchivedWorkspaceSubdomain

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

  ####################
  # Changeset funcs #
  ####################
  def changeset_create(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_format(:workspace_subdomain, Utils.Regex.get_subdomain_regex())
    |> unique_constraint(:workspace_subdomain)
  end

  def changeset_update(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_format(:workspace_subdomain, Utils.Regex.get_subdomain_regex())
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
  def get_workspace(workspace_id), do: Repo.get(ApiGateway.Models.Workspace, workspace_id)

  def get_workspace_by_subdomain(subdomain) do
    Repo.get_by(ApiGateway.Models.Workspace, workspace_subdomain: subdomain)
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

  defp check_subdomain_taken(subdomain) do
    internal = InternalSubdomain.get_internal_subdomain_by_subdomain(subdomain)

    archived = ArchivedWorkspaceSubdomain.get_archived_workspace_subdomain_by_subdomain(subdomain)

    if internal || archived, do: true, else: false
  end
end
