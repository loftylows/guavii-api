defmodule ApiGateway.Models.User do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :profile_description, :string
    field :profile_role, :string
    field :phone_number, :string
    field :birthday, :utc_datetime
    field :location, :string
    field :profile_pic_url, :string
    field :last_Login, :utc_datetime
    field :workspace_role, :string
    field :billing_status, :string
    field :sessionId, :string
    field :password_hash, :string

    embeds_one :time_zone, TimeZone do
      field :offset, :string
      field :name, :string
    end

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :full_name,
    :email,
    :profile_description,
    :profile_role,
    :phone_number,
    :birthday,
    :location,
    :profile_pic_url,
    :workspace_role,
    :sessionId,
    :password_hash,
    :workspace_id
  ]
  @required_fields_create [
    :full_name,
    :email,
    :workspace_role,
    :password_hash,
    :workspace_id
  ]

  @time_zone_permitted_fields [
    :offset,
    :name
  ]

  def changeset_create(%ApiGateway.Models.User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:time_zone, with: &time_zone_changeset/2)
    |> validate_required(@required_fields_create)
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, ApiGateway.Models.Workspace.get_workspace_roles())
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(%ApiGateway.Models.User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:child, with: &time_zone_changeset/2)
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, ApiGateway.Models.Workspace.get_workspace_roles())
    |> foreign_key_constraint(:workspace_id)
  end

  def time_zone_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @time_zone_permitted_fields)
    |> validate_required(@time_zone_permitted_fields)
  end
end
