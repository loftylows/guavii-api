defmodule ApiGateway.Repo.Migrations.CreateKanbanCardsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_cards) do
      add(:title, :string, null: false)
      add(:description, :text)
      add(:completed, :boolean, default: false)
      add(:attachments, {:array, :string})
      add(:due_date_range, :map)
      add :list_order_rank, :float, null: false

      add(:kanban_lane_id, references("kanban_lanes", on_delete: :delete_all), null: false)
      add(:project_id, references("projects", on_delete: :delete_all), null: false)
      add(:user_id, references("users", on_delete: :nilify_all))

      timestamps()
    end

    create unique_index("kanban_cards", [:list_order_rank])
  end
end
