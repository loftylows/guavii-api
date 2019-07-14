defmodule ApiGateway.Repo.Migrations.CreateProjectMembersTable do
  use Ecto.Migration

  def change do
    create table(:project_members) do
      add :project_id, references("projects", :on_delete :delete_all), null: false
      add :user_id, references("users", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
