defmodule ApiGateway.Repo.Migrations.CreateKanbanCardCommentsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_card_comments) do
      add :content, :text, null: false

      add :kanban_card_id, references("kanban_cards", :on_delete :delete_all), null: false
      add :user_id, references("users", :on_delete :nilify_all)

      timestamps(type: :utc_datetime)
    end
  end
end
