defmodule ApiGateway.Repo.Migrations.CreateForgotPasswordInvitationsTable do
  use Ecto.Migration

  def change do
    create table(:forgot_password_invitations) do
      add(:token_hashed, :string, null: false)
      add(:accepted, :boolean, null: false, default: false)

      add(:user_id, references("users", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index("forgot_password_invitations", [:token_hashed]))
    create(unique_index("forgot_password_invitations", [:user_id]))
    create(index(:forgot_password_invitations, [:accepted]))
  end
end
