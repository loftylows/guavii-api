defmodule ApiGateway.Repo.Migrations.CreateProjectTodoListsTable do
  use Ecto.Migration

  def change do
    create table(:project_todo_lists) do
      add :title, :string, null: false
      add :list_order_rank, :float, null: false

      add :project_lists_board_id, references("project_lists_boards", on_delete: :delete_all),
        null: false

      add :project_id, references("projects", on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index("project_todo_lists", [:list_order_rank])
  end
end
