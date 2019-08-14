defmodule ApiGateway.Models.ArchivedWorkspaceSubdomain do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "archived_workspace_subdomains" do
    field :subdomain, :string

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :subdomain,
    :workspace_id
  ]
  @required_fields [
    :subdomain,
    :workspace_id
  ]

  def changeset_create(
        %ApiGateway.Models.ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
        attrs \\ %{}
      ) do
    archived_workspace_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:subdomain)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(
        %ApiGateway.Models.ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
        attrs \\ %{}
      ) do
    archived_workspace_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:subdomain)
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
    |> Ecto.Query.join(
      :inner,
      [archived_workspace_subdomain],
      workspace in ApiGateway.Models.Workspace,
      on: archived_workspace_subdomain.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([archived_workspace_subdomain, workspace], archived_workspace_subdomain)
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
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "archived_workspace_subdomain_id must be a valid 'uuid' or an error will raise"
  def get_archived_workspace_subdomain(archived_workspace_subdomain_id) do
    Repo.get(ApiGateway.Models.ArchivedWorkspaceSubdomain, archived_workspace_subdomain_id)
  end

  def get_archived_workspace_subdomain_by_subdomain(subdomain) do
    Repo.get_by(ApiGateway.Models.ArchivedWorkspaceSubdomain, subdomain: subdomain)
  end

  def get_archived_workspace_subdomains(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.ArchivedWorkspaceSubdomain |> add_query_filters(filters) |> Repo.all()
  end

  def create_archived_workspace_subdomain(data) when is_map(data) do
    %ApiGateway.Models.ArchivedWorkspaceSubdomain{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_archived_workspace_subdomain(%{id: id, data: data}) do
    case get_archived_workspace_subdomain(id) do
      nil ->
        {:error, "Not found"}

      archived_workspace_subdomain ->
        archived_workspace_subdomain
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_archived_workspace_subdomain(id) do
    case get_archived_workspace_subdomain(id) do
      nil ->
        {:error, "Not found"}

      archived_workspace_subdomain ->
        Repo.delete(archived_workspace_subdomain)
    end
  end
end
