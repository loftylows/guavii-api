defmodule ApiGateway.Repo.Migrations.CreateSubListsTable do
  use Ecto.Migration

  def change do
    create table(:sub_lists) do
      add :title, :string

      add :project_todo_list_id, references("project_todo_lists", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
