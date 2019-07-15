defmodule ApiGateway.Repo.Migrations.CreateFindMyWorkspacesInvitationsTable do
  use Ecto.Migration

  def change do
    create table(:find_my_workspaces_invitations) do
      add :email, :string, null: false
      add :token_hashed, :string, null: false

      timestamps()
    end

    create unique_index("find_my_workspaces_invitations", [:email])
    create unique_index("find_my_workspaces_invitations", [:token_hashed])
  end
end
