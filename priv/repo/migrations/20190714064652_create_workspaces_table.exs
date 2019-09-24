defmodule ApiGateway.Repo.Migrations.CreateWorkspacesTable do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :title, :string, null: false
      add :workspace_subdomain, :string, null: false
      add :description, :text
      add :storage_cap, :integer, null: false, default: 5
      add :member_cap, :integer, null: false, default: 5

      timestamps()
    end

    create unique_index("workspaces", [:workspace_subdomain])
    create constraint("workspaces", :storage_cap_must_be_positive, check: "storage_cap >= 0")
    create constraint("workspaces", :member_cap_must_be_positive, check: "member_cap >= 0")
  end
end
