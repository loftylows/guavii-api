defmodule ApiGateway.Repo.Migrations.CreateWorkspaceInvitationsTable do
  use Ecto.Migration
  alias ApiGateway.Models.Workspace

  def change do
    create table(:workspace_invitations) do
      add(:email, :string, null: false)
      add(:invitation_token_hashed, :string, null: false)
      add(:accepted, :boolean, null: false, default: false)
      add(:workspace_role, :string, null: false, default: Workspace.get_default_workspace_role())

      add(:workspace_id, references("workspaces", on_delete: :delete_all), null: false)
      add(:invited_by_id, references("users", on_delete: :nilify_all))

      timestamps()
    end

    create(
      unique_index("workspace_invitations", [:email, :workspace_id],
        name: "unique_email_workspace_id_workspace_invitation"
      )
    )

    create(unique_index("workspace_invitations", [:invitation_token_hashed]))

    create(index(:workspace_invitations, [:workspace_id]))
    create(index(:workspace_invitations, [:accepted]))
    create(index(:workspace_invitations, [:invited_by_id]))
  end
end
