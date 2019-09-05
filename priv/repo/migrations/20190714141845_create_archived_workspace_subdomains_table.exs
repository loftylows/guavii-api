defmodule ApiGateway.Repo.Migrations.CreateArchivedWorkspaceSubdomainsTable do
  use Ecto.Migration

  def change do
    create table(:archived_workspace_subdomains) do
      add(:subdomain, :string, null: false)

      add(:workspace_id, references("workspaces", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index("archived_workspace_subdomains", [:subdomain]))
    create(index(:archived_workspace_subdomains, [:workspace_id]))
  end
end
