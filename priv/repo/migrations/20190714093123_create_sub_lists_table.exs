defmodule ApiGateway.Repo.Migrations.CreateSubListsTable do
  use Ecto.Migration

  def change do
    create table(:sub_lists) do
      add(:title, :string)

      add(:project_todo_id, references("project_todos", on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
