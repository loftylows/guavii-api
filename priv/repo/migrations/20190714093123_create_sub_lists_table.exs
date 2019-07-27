defmodule ApiGateway.Repo.Migrations.CreateSubListsTable do
  use Ecto.Migration

  def change do
    create table(:sub_lists) do
      add(:title, :string)
      add :list_order_rank, :float, null: false

      add(:project_todo_id, references("project_todos", on_delete: :delete_all), null: false)

      timestamps()
    end

    create unique_index("sub_lists", [:list_order_rank])
  end
end
