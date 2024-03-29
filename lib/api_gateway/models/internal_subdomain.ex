defmodule ApiGateway.Models.InternalSubdomain do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "internal_subdomains" do
    field :subdomain, :string

    timestamps()
  end

  @permitted_fields [
    :subdomain
  ]
  @required_fields [
    :subdomain
  ]

  def changeset_create(
        %ApiGateway.Models.InternalSubdomain{} = internal_subdomain,
        attrs \\ %{}
      ) do
    internal_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
  end

  def changeset_update(
        %ApiGateway.Models.InternalSubdomain{} = internal_subdomain,
        attrs \\ %{}
      ) do
    internal_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
  end

  ####################
  # Query helpers #
  ####################
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
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "internal_subdomain_id must be a valid 'uuid' or an error will raise"
  def get_internal_subdomain(internal_subdomain_id) do
    Repo.get(ApiGateway.Models.InternalSubdomain, internal_subdomain_id)
  end

  def get_internal_subdomain_by_subdomain(subdomain) do
    Repo.get_by(ApiGateway.Models.InternalSubdomain, subdomain: subdomain)
  end

  def get_internal_subdomains(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.InternalSubdomain |> add_query_filters(filters) |> Repo.all()
  end

  def create_internal_subdomain(data) when is_map(data) do
    %ApiGateway.Models.InternalSubdomain{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_internal_subdomain(%{id: id, data: data}) do
    case get_internal_subdomain(id) do
      nil ->
        {:error, "Not found"}

      internal_subdomain ->
        internal_subdomain
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_internal_subdomain(id) do
    case get_internal_subdomain(id) do
      nil ->
        {:error, "Not found"}

      internal_subdomain ->
        Repo.delete(internal_subdomain)
    end
  end
end
