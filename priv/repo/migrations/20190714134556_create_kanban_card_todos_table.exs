defmodule ApiGateway.Repo.Migrations.CreateKanbanCardTodosTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_todos) do
      add(:title, :string, null: false)
      add(:completed, :boolean, null: false, default: false)
      add(:due_date, :utc_datetime)
      add(:list_order_rank, :float, null: false)

      add(:kanban_card_todo_list_id, references("kanban_card_todo_lists", on_delete: :delete_all),
        null: false
      )

      add(:user_id, references("users", on_delete: :nilify_all))
      add(:card_id, references("kanban_cards", on_delete: :delete_all), null: false)
      add(:project_id, references("projects", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:kanban_card_todos, [:list_order_rank]))
    create(index(:kanban_card_todos, [:card_id]))
    create(index(:kanban_card_todos, [:project_id]))
    create(index(:kanban_card_todos, [:completed]))
    create(index(:kanban_card_todos, [:title]))
    create(index(:kanban_card_todos, [:due_date]))
  end
end
