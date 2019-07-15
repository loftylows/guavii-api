defmodule ApiGateway.Models.AccountInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "account_invitations" do
    field :email, :string
    field :invitation_token_hashed, :string
    field :accepted, :boolean

    timestamps()
  end

  @permitted_fields [
    :email,
    :invitation_token_hashed,
    :accepted
  ]
  @required_fields_create [
    :email,
    :invitation_token_hashed,
    :accepted
  ]

  def changeset_create(%ApiGateway.Models.AccountInvitation{} = account_invitation, attrs \\ %{}) do
    account_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
  end

  def changeset_update(%ApiGateway.Models.AccountInvitation{} = account_invitation, attrs \\ %{}) do
    account_invitation
    |> cast(attrs, @permitted_fields)
  end
end
