defmodule ApiGateway.Repo.Migrations.CreateDocumentLastUpdateTables do
  use Ecto.Migration

  def change do
    create table(:document_last_updates) do
      add(:date, :utc_datetime, null: false)

      add(:user_id, references("users", on_delete: :nilify_all), null: false)
      add(:document_id, references("documents", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index("document_last_updates", [:document_id]))
    create(index(:document_last_updates, [:date]))
  end
end
