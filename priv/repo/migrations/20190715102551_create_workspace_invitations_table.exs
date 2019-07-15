defmodule ApiGateway.Repo.Migrations.CreateWorkspaceInvitationsTable do
  use Ecto.Migration

  def change do
    create table(:workspace_invitations) do
      add :email, :string, null: false
      add :invitation_token_hashed, :string, null: false
      add :accepted, :boolean, null: false

      add :workspace_id, references("workspaces", on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index("workspace_invitations", [:email])
    create unique_index("workspace_invitations", [:invitation_token_hashed])
  end
end
