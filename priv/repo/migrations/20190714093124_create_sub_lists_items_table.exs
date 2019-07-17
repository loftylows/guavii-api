defmodule ApiGateway.Repo.Migrations.CreateSubListsItemsTable do
  use Ecto.Migration

  def change do
    create table(:sub_list_items) do
      add(:title, :string, null: false)
      add(:description, :text)
      add(:completed, :boolean, null: false, default: false)
      add(:attachments, {:array, :string})
      add(:due_date_range, :map)

      add(:user_id, references("users", on_delete: :nilify_all))
      add(:sub_list_id, references("sub_lists", on_delete: :delete_all), null: false)
      add(:project_id, references("projects", on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
