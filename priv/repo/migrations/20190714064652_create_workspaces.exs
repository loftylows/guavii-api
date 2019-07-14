defmodule ApiGateway.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :title, :string, null: false
      add :workspace_subdomain, :string, null: false
      add :description, :text
      add :storage_cap, :integer, null: false

      timestamps()

      unique_index("workspaces", [:workspace_subdomain])
    end

    create constraint("workspaces", :storage_cap_must_be_positive, check: "storage_cap >= 0")
  end
end
