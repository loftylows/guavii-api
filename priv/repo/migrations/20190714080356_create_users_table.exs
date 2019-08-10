defmodule ApiGateway.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :full_name, :string, null: false
      add :profile_description, :text
      add :profile_role, :string
      add :phone_number, :string
      add :location, :string
      add :birthday, :utc_datetime
      add :profile_pic_url, :string
      add :last_login, :utc_datetime
      add :workspace_role, :string, null: false
      add :billing_status, :string, null: false
      add :password_hash, :string, null: false

      add :time_zone, :map

      add :workspace_id, references("workspaces", on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index("users", [:email, :workspace_id], name: "unique_workspace_email_index")
  end
end
