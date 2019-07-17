defmodule ApiGateway.Models.Workspace do
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
    :storage_cap,
    :members,
    :teams
  ]
  @required_fields_create [
    :title,
    :workspace_subdomain,
    :storage_cap
  ]

  def get_workspace_roles do
    [
      "PRIMARY_OWNER",
      "OWNER",
      "ADMIN",
      "MEMBER"
    ]
  end

  def changeset_create(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
  end

  def changeset_update(%ApiGateway.Models.Workspace{} = workspace, attrs \\ %{}) do
    workspace
    |> cast(attrs, @permitted_fields)
  end

  ####################
  # Query helpers #
  ####################

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
  end

  ####################
  # Queries #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will raise"
  def get_workspace(workspace_id), do: Repo.get(ApiGateway.Models.Workspace, workspace_id)

  def get_workspaces(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Workspace |> add_query_filters(filters) |> Repo.all()
  end
end
