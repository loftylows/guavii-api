defmodule ApiGateway.Repo.Migrations.CreateKanbanCardTodoListsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_todo_lists) do
      add :title, :string, null: false

      add :kanban_card_id, references("kanban_cards", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
