defmodule ApiGateway.Repo.Migrations.CreateKanbanBoardsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_boards) do
      add :name, :string, null: false

      add :project_id, references("projects", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
