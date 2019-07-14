defmodule ApiGateway.Repo.Migrations.CreateKanbanLanesTable do
  use Ecto.Migration

  def change do
    create table(:kanban_lanes) do
      add(:title, :string, null: false)
      add(:lane_color, :string, null: false)

      add(:kanban_board_id, references("kanban_boards", on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
