defmodule ApiGateway.Models.Document do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "projects" do
    field :title, :string
    field :content, :string
    field :is_pinned, :boolean

    embeds_one :last_update, LastUpdate do
      field :date, :utc_datetime

      belongs_to :user, ApiGateway.Models.User
    end

    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :content,
    :is_pinned,
    :last_update,
    :project_id
  ]
  @required_fields_create [
    :title,
    :content,
    :last_update,
    :project_id
  ]

  @last_update_permitted_fields [
    :date,
    :user_id
  ]

  def changeset_create(%ApiGateway.Models.Document{} = document, attrs \\ %{}) do
    document
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:last_update, with: &last_update_changeset/2)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.Document{} = document, attrs \\ %{}) do
    document
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:last_update, with: &last_update_changeset/2)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:project_id)
  end

  def last_update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @last_update_permitted_fields)
    |> validate_required(@last_update_permitted_fields)
  end
end
