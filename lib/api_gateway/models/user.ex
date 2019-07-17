defmodule ApiGateway.Models.User do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :profile_description, :string
    field :profile_role, :string
    field :phone_number, :string
    field :birthday, :utc_datetime
    field :location, :string
    field :profile_pic_url, :string
    field :last_login, :utc_datetime
    field :workspace_role, :string
    field :billing_status, :string
    field :session_id, :string
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

  ####################
  # Query helpers #
  ####################
  def maybe_full_name_contains_filter(query, field \\ "")

  def maybe_full_name_contains_filter(query, field) when is_binary(field) do
    query |> Ecto.Query.where([p], like(p.full_name, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_full_name_contains_filter(query, _) do
    query
  end

  def maybe_billing_status_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.where([p], p.billing_status == ^bool)
  end

  def maybe_billing_status_filter(query, _) do
    query
  end

  def maybe_last_login_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_filter(query, date) do
    query |> Ecto.Query.where([p], p.last_login == ^date)
  end

  def maybe_last_login_gte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_gte_filter(query, date) do
    query |> Ecto.Query.where([p], p.last_login >= ^date)
  end

  def maybe_last_login_lte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_lte_filter(query, date) do
    query |> Ecto.Query.where([p], p.last_login <= ^date)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_full_name_contains_filter(filters[:full_name_contains])
    |> maybe_billing_status_filter(filters[:billing_status])
    |> maybe_last_login_filter(filters[:last_login])
    |> maybe_last_login_gte_filter(filters[:last_login_gte])
    |> maybe_last_login_lte_filter(filters[:last_login_lte])
  end

  ####################
  # Queries #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will raise"
  def get_user(user_id), do: Repo.get(ApiGateway.Models.User, user_id)

  def get_users(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.User |> add_query_filters(filters) |> Repo.all()
  end
end
