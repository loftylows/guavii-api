defmodule ApiGateway.Models.DocumentLastUpdate do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias __MODULE__

  schema("document_last_updates") do
    field :date, :utc_datetime

    belongs_to :user, ApiGateway.Models.Account.User

    belongs_to :document, ApiGateway.Models.Document

    timestamps()
  end

  @permitted_fields [
    :date,
    :user_id,
    :document_id
  ]

  def changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @permitted_fields)
    |> validate_required(@permitted_fields)
  end

  def create_last_update(data) do
    %DocumentLastUpdate{}
    |> changeset(data)
    |> Repo.insert()
  end
end
