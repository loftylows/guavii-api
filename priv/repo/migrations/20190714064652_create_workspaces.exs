defmodule ApiGateway.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :title, :string, null: false
      add :workspace_subdomain, :string, null: false
      add :description, :text
      add :storage_cap, :integer, null: false, default: 5

      timestamps()

      create index("workspaces", [:workspace_subdomain], unique: true)
      create constraint("workspaces", :storage_cap_must_be_positive, check: "storage_cap >= 0")
    end
  end
end
