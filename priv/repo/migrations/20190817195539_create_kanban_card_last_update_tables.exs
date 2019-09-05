defmodule ApiGateway.Repo.Migrations.CreateKanbanCardLastUpdateTables do
  use Ecto.Migration

  def change do
    create table(:kanban_card_last_updates) do
      add(:date, :utc_datetime, null: false)

      add(:user_id, references("users", on_delete: :nilify_all), null: false)
      add(:kanban_card_id, references("kanban_cards", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index("kanban_card_last_updates", [:kanban_card_id]))
    create(index(:kanban_card_last_updates, [:date]))
  end
end
