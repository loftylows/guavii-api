defmodule ApiGateway.Repo.Migrations.CreateProjectTodosTable do
  use Ecto.Migration

  def change do
    create table(:project_todos) do
      add(:title, :string, null: false)
      add(:description, :text)
      add(:completed, :boolean, default: false)
      add(:attachments, {:array, :string}, default: [])
      add(:due_date_range, :map)
      add(:list_order_rank, :float, null: false)

      add(:project_todo_list_id, references("project_todo_lists", on_delete: :delete_all),
        null: false
      )

      add(:project_id, references("projects", on_delete: :delete_all), null: false)
      add(:user_id, references("users", on_delete: :nilify_all))

      timestamps()
    end

    create(index(:project_todos, [:project_todo_list_id]))
    create(index(:project_todos, [:project_id]))
    create(index(:team_members, [:team_id]))
  end
end
