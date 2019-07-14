defmodule ApiGateway.Repo.Migrations.CreateDocumentsTable do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string, null: false
      add :content, :text
      add :is_pinned, :boolean
      add :last_update, :map

      add :project_id, references("projects", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
