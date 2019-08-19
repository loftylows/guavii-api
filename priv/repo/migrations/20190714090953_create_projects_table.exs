defmodule ApiGateway.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add(:title, :string, null: false)
      add(:description, :text)

      add(:privacy_policy, :string,
        null: false,
        default: ApiGateway.Models.Project.get_project_privacy_policy_default()
      )

      add(:project_type, :string, null: false)

      add(:status, :string,
        null: false,
        default: ApiGateway.Models.Project.get_project_status_default()
      )

      add(:workspace_id, references("workspaces", on_delete: :delete_all), null: false)
      add(:team_id, references("teams", on_delete: :delete_all), null: false)
      add(:created_by_id, references("users", on_delete: :nilify_all))

      timestamps()
    end
  end
end
