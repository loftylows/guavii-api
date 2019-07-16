defmodule ApiGateway.Repo.Migrations.CreateSubListItemCommentsTable do
  use Ecto.Migration

  def change do
    create table(:sub_list_item_comments) do
      add(:content, :text, null: false)
      add(:edited, :boolean, null: false, default: false)

      add(:sub_list_item_id, references("sub_list_items", on_delete: :delete_all), null: false)
      add(:user_id, references("users", on_delete: :nilify_all))

      timestamps()
    end
  end
end
