defmodule ApiGateway.Models.Workspace do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "workspaces" do
    field :title, :string
    field :workspace_subdomain, :string
    field :description, :string
    field :storage_cap, :integer

    has_many :members, ApiGateway.Models.User
    has_many :teams, ApiGateway.Models.Team
    has_many :archived_workspace_subdomains, ApiGateway.Models.ArchivedWorkspaceSubdomain

    timestamps()
  end

  @permitted_fields [
    :title,
    :workspace_subdomain,
    :description,
    :storage_cap
    # :members,
    # :teams
  ]
  @required_fields_create [
    :title,
    :workspace_subdomain
  ]

  def get_workspace_roles do
    [
      "PRIMARY_OWNER",
      "OWNER",
      "ADMIN",
      "MEMBER"
    ]
  end

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

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
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

  def create_workspace(data) when is_map(data) do
    %ApiGateway.Models.Workspace{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_workspace(%{id: id, data: data}) do
    case get_workspace(id) do
      nil ->
        {:error, "Not found"}

      workspace ->
        workspace
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_workspace(%{workspace_subdomain: subdomain, data: data}) do
    case get_workspace_by_subdomain(subdomain) do
      nil ->
        {:error, "Not found"}

      workspace ->
        workspace
        |> changeset_update(data)
        |> Repo.update()
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
end
