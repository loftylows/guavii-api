defmodule ApiGateway.Repo.Migrations.CreateAccountInvitationsTable do
  use Ecto.Migration

  def change do
    create table(:account_invitations) do
      add :email, :string, null: false
      add :invitation_token_hashed, :string, null: false
      add :accepted, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index("account_invitations", [:email])
    create unique_index("account_invitations", [:invitation_token_hashed])
  end
end
