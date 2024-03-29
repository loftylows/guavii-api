defmodule ApiGateway.Repo.Migrations.CreateKanbanCardTodoListsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_todo_lists) do
      add(:title, :string, null: false)
      add(:list_order_rank, :float, null: false)

      add(:kanban_card_id, references("kanban_cards", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index("kanban_card_todo_lists", [:list_order_rank]))
    create(index(:kanban_card_todo_lists, [:kanban_card_id]))
  end
end
