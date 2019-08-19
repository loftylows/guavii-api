defmodule ApiGateway.Repo.Migrations.CreateDocumentsTable do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add(:title, :string, null: false)
      add :content, :text, null: false, default: ""
      add :is_pinned, :boolean, default: false

      add(:project_id, references("projects", on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
