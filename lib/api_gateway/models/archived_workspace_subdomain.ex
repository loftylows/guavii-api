defmodule ApiGateway.Models.ArchivedWorkspaceSubdomain do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias __MODULE__

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

  # 15 days in seconds
  @archived_domain_lifespan_in_seconds 1.296e+6 |> Kernel.trunc()

  def get_archived_domain_lifespan_in_seconds, do: @archived_domain_lifespan_in_seconds

  def changeset_create(
        %ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
        attrs \\ %{}
      ) do
    archived_workspace_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:subdomain)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(
        %ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
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
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "archived_workspace_subdomain_id must be a valid 'uuid' or an error will raise"
  def get_archived_workspace_subdomain(archived_workspace_subdomain_id) do
    Repo.get(ArchivedWorkspaceSubdomain, archived_workspace_subdomain_id)
  end

  def get_archived_workspace_subdomain_by_subdomain(subdomain) do
    subdomain = String.downcase(subdomain)
    Repo.get_by(ArchivedWorkspaceSubdomain, subdomain: subdomain)
  end

  def get_archived_workspace_subdomains(filters \\ %{}) do
    IO.inspect(filters)

    ArchivedWorkspaceSubdomain |> add_query_filters(filters) |> Repo.all()
  end

  def create_archived_workspace_subdomain(data) when is_map(data) do
    %ArchivedWorkspaceSubdomain{}
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

  @doc """
  Deletes out of date archived domain items in the db according to
  the set archived domain lifespan
  """
  def delete_out_of_date_archived_domains do
    date_now = DateTime.truncate(DateTime.utc_now(), :second)

    {:ok, date_15_days_earlier} =
      (DateTime.to_unix(date_now) - get_archived_domain_lifespan_in_seconds())
      |> DateTime.from_unix()

    ArchivedWorkspaceSubdomain
    |> Ecto.Query.where([x], x.inserted_at < ^date_15_days_earlier)
    |> Repo.delete_all()
  end
end
