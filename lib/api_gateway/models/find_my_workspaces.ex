defmodule ApiGateway.Models.FindMyWorkspacesInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "find_my_workspaces_invitations" do
    field :email, :string
    field :token_hashed, :string

    timestamps()
  end

  @permitted_fields [
    :email,
    :token_hashed
  ]
  @required_fields_create [
    :email,
    :token_hashed
  ]

  def changeset_create(
        %ApiGateway.Models.FindMyWorkspacesInvitation{} = find_my_workspaces_invitation,
        attrs \\ %{}
      ) do
    find_my_workspaces_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
  end

  def changeset_update(
        %ApiGateway.Models.FindMyWorkspacesInvitation{} = find_my_workspaces_invitation,
        attrs \\ %{}
      ) do
    find_my_workspaces_invitation
    |> cast(attrs, @permitted_fields)
  end
end
