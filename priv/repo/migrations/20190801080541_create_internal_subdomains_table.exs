defmodule ApiGateway.Repo.Migrations.CreateInternalSubdomainsTable do
  use Ecto.Migration

  def change do
    create table(:internal_subdomains) do
      add :subdomain, :string, null: false

      timestamps()
    end

    create unique_index("internal_subdomains", [:subdomain])
  end
end
