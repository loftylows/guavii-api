defmodule ApiGateway.Models.Workspace do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "workspaces" do
    field :title, :string
    field :workspace_subdomain, :string
    field :description, :string
    field :storage_cap, :integer

    has_many :members, ApiGateway.Models.User
    has_many :teams, ApiGateway.Models.Team

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
end
