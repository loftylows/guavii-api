defmodule ApiGateway.Repo.Migrations.CreateProjectMembersTable do
  use Ecto.Migration

  def change do
    create table(:project_members, primary_key: false) do
      add(:project_id, references("projects", on_delete: :delete_all, type: :uuid),
        null: false,
        primary_key: true
      )

      add(:user_id, references("users", on_delete: :delete_all, type: :uuid),
        null: false,
        primary_key: true
      )

      timestamps()
    end

    create(index(:project_members, [:project_id]))
    create(index(:project_members, [:user_id]))

    create(
      unique_index(
        :project_members,
        [:project_id, :user_id],
        name: :unique_project_members_index
      )
    )
  end
end
