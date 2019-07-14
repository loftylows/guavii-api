defmodule ApiGateway.Repo.Migrations.CreateTeamsTable do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :title, :string, null: false
      add :description, :text

      add :workspace_id, references("workspaces", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
