defmodule ApiGateway.Repo.Migrations.CreateKanbanLabelsTable do
  use Ecto.Migration

  def change do
    create table(:kanban_labels) do
      add(:title, :string, null: false)
      add(:color, :string, null: false)

      add(:kanban_board_id, references("kanban_boards", on_delete: :delete_all), null: false)

      timestamps()
    end

    create index("kanban_labels", [:color])
  end
end
