defmodule ApiGateway.Repo.Migrations.CreateKanbanCardActiveLabelsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_active_labels, primary_key: false) do
      add :kanban_card_id, references("kanban_cards", on_delete: :delete_all, type: :uuid),
        null: false,
        primary_key: true

      add :kanban_label_id, references("kanban_labels", on_delete: :delete_all, type: :uuid),
        null: false,
        primary_key: true

      timestamps()
    end

    create(index(:kanban_card_active_labels, [:kanban_card_id]))
    create(index(:kanban_card_active_labels, [:kanban_label_id]))

    create(
      unique_index(
        :kanban_card_active_labels,
        [:kanban_card_id, :kanban_label_id],
        name: :unique_kanban_cards_active_labels_index
      )
    )
  end
end
