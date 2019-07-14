defmodule ApiGateway.Models.ArchivedWorkspaceSubdomain do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "archived_workspace_subdomain" do
    field :subdomain, :string

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :subdomain,
    :workspace_id
  ]
  @required_fields_create [
    :subdomain,
    :workspace_id
  ]

  def changeset_create(
        %ApiGateway.Models.ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
        attrs \\ %{}
      ) do
    archived_workspace_subdomain
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(
        %ApiGateway.Models.ArchivedWorkspaceSubdomain{} = archived_workspace_subdomain,
        attrs \\ %{}
      ) do
    archived_workspace_subdomain
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:workspace_id)
  end
end
