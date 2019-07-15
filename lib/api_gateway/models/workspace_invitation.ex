defmodule ApiGateway.Models.WorkspaceInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "workspace_invitations" do
    field :email, :string
    field :invitation_token_hashed, :string
    field :accepted, :boolean

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :email,
    :invitation_token_hashed,
    :accepted,
    :workspace_id
  ]
  @required_fields_create [
    :email,
    :invitation_token_hashed,
    :accepted,
    :workspace_id
  ]

  def changeset_create(
        %ApiGateway.Models.WorkspaceInvitation{} = workspace_invitation,
        attrs \\ %{}
      ) do
    workspace_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(
        %ApiGateway.Models.WorkspaceInvitation{} = workspace_invitation,
        attrs \\ %{}
      ) do
    workspace_invitation
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:workspace_id)
  end
end
