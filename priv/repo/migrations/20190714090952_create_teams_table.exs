defmodule ApiGateway.Repo.Migrations.CreateTeamsTable do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:title, :string, null: false)
      add(:description, :text)

      add(:workspace_id, references("workspaces", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:teams, [:workspace_id]))
  end
end
