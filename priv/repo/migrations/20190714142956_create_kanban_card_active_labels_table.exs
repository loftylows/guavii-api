defmodule ApiGateway.Repo.Migrations.CreateKanbanCardActiveLabelsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_active_labels) do
      add :kanban_card_id, references("kanban_cards", :on_delete :delete_all), null: false
      add :kanban_label_id, references("kanban_labels", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
