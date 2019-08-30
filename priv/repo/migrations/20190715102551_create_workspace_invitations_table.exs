defmodule ApiGateway.Repo.Migrations.CreateWorkspaceInvitationsTable do
  use Ecto.Migration

  def change do
    create table(:workspace_invitations) do
      add :email, :string, null: false
      add :invitation_token_hashed, :string, null: false
      add :accepted, :boolean, null: false, default: false

      add :workspace_id, references("workspaces", on_delete: :delete_all), null: false
      add :team_id, references("teams", on_delete: :delete_all), null: false
      add :invited_by_id, references("users", on_delete: :nilify_all)

      timestamps()
    end

    create unique_index("workspace_invitations", [:email, :team_id],
             name: "unique_email_team_id_workspace_invitation"
           )

    create unique_index("workspace_invitations", [:invitation_token_hashed])
  end
end
