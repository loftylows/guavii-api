defmodule ApiGateway.Repo.Migrations.CreateProjectListsBoardTable do
  use Ecto.Migration

  def change do
    create table(:project_lists_boards) do
      add(:project_id, references("projects", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:project_lists_boards, [:project_id]))
  end
end
