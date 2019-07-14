defmodule ApiGateway.Repo.Migrations.CreateProjectTodoListsTable do
  use Ecto.Migration

  def change do
    create table(:project_todo_lists) do
      add :name, :string, null: false
      add :description, :text

      add :project_id, references("projects", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
