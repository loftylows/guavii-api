defmodule ApiGateway.Repo.Migrations.CreateKanbanBoardsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_boards) do
      add(:project_id, references("projects", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:kanban_boards, [:project_id]))
  end
end
