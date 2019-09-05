defmodule ApiGateway.Repo.Migrations.CreateTeamMembersTable do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add(:role, :string)

      add(:user_id, references("users", on_delete: :delete_all), null: false)
      add(:team_id, references("teams", on_delete: :delete_all), null: false)

      timestamps()
    end

    create(
      unique_index(:team_members, [:user_id, :team_id],
        name: "unique_team_member_user_id_and_team_id_index"
      )
    )

    create(index(:team_members, [:user_id]))
  end
end
