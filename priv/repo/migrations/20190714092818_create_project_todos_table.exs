defmodule ApiGateway.Repo.Migrations.CreateProjectTodosTable do
  use Ecto.Migration

  def change do
    create table(:project_todos) do
      add(:title, :string, null: false)
      add(:description, :text)
      add(:completed, :boolean, default: false)
      add(:attachments, {:array, :string})
      add(:due_date_range, :map)

      add(:project_todo_list_id, references("project_todo_lists", on_delete: :delete_all),
        null: false
      )

      add(:project_id, references("projects", on_delete: :delete_all), null: false)
      add(:user_id, references("users", on_delete: :nilify_all))

      timestamps()
    end
  end
end
