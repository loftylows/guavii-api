defmodule ApiGateway.Repo.Migrations.CreateArchivedWorkspaceSubdomainsTable do
  use Ecto.Migration

  def change do
    create table(:archived_workspace_subdomains) do
      add :subdomain, :string, null: false

      add :workspace_id, references("workspaces", :on_delete :delete_all), null: false

      unique_index("archived_workspace_subdomains", [:subdomain])

      timestamps(type: :utc_datetime)
    end
  end
end
