defmodule ApiGateway.Models.ForgotPasswordInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "forgot_password_invitations" do
    field :token_hashed, :string
    field :accepted, :boolean

    belongs_to :user, ApiGateway.Models.User

    timestamps()
  end

  @permitted_fields [
    :email,
    :token_hashed,
    :accepted,
    :user_id
  ]
  @required_fields_create [
    :email,
    :token_hashed,
    :accepted,
    :user_id
  ]

  def changeset_create(
        %ApiGateway.Models.ForgotPasswordInvitation{} = forgot_password_invitation,
        attrs \\ %{}
      ) do
    forgot_password_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(
        %ApiGateway.Models.ForgotPasswordInvitation{} = forgot_password_invitation,
        attrs \\ %{}
      ) do
    forgot_password_invitation
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:user_id)
  end
end
