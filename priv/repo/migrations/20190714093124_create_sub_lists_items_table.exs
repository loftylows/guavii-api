defmodule ApiGateway.Repo.Migrations.CreateSubListsItemsTable do
  use Ecto.Migration

  def change do
    create table(:sub_list_items) do
      add :title, :string, null: false
      add :description, :text
      add :completed, :boolean, null: false, default: false
      add :attachments, {:array, :string}
      add :due_date_range, :map

      add :workspace_id, references("workspaces", :on_delete :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
