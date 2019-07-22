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
    field :password, :string, virtual: true
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
    :session_id,
    :password,
    :password_hash,
    :workspace_id
  ]
  @required_fields_create [
    :full_name,
    :email,
    :workspace_role,
    :workspace_id,
    :password
  ]

  @required_fields_update [
    :full_name,
    :email,
    :workspace_role,
    :workspace_id,
    :password_hash
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
    |> validate_length(:password, min: 8, max: 100, message: "should be at least 8 characters")
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, ApiGateway.Models.Workspace.get_workspace_roles())
    # continues validation if changeset still valid or returns the changeset right away
    # TODO: refactor this
    |> continue_if_valid()
  end

  def continue_if_valid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> maybe_put_pass_hash()
    |> validate_required([:password_hash])
    |> foreign_key_constraint(:workspace_id)
  end

  def continue_if_valid(changeset) do
    changeset
  end

  def changeset_update(%ApiGateway.Models.User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:child, with: &time_zone_changeset/2)
    |> validate_required(@required_fields_update)
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, ApiGateway.Models.Workspace.get_workspace_roles())
    |> validate_length(:password,
      min: 8,
      max: 100,
      message: "must be between 8 and 100 characters"
    )
    |> maybe_put_pass_hash()
    |> foreign_key_constraint(:workspace_id)
    |> unique_constraint(:email, name: :unique_workspace_email_index)
  end

  def time_zone_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @time_zone_permitted_fields)
    |> validate_required(@time_zone_permitted_fields)
    |> unique_constraint(:email, name: :unique_workspace_email_index)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_email_in_filter(query, list \\ [])

  def maybe_email_in_filter(query, list) when is_list(list) and length(list) > 0 do
    query |> Ecto.Query.where([p], p.email in ^list)
  end

  def maybe_email_in_filter(query, _) do
    query
  end

  def maybe_full_name_contains_filter(query, field \\ "")

  def maybe_full_name_contains_filter(query, field) when is_binary(field) do
    query
    |> Ecto.Query.where([user], like(user.full_name, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_full_name_contains_filter(query, _) do
    query
  end

  def maybe_billing_status_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.where([user], user.billing_status == ^bool)
  end

  def maybe_billing_status_filter(query, _) do
    query
  end

  def maybe_last_login_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_filter(query, date) do
    query |> Ecto.Query.where([user], user.last_login == ^date)
  end

  def maybe_last_login_gte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_gte_filter(query, date) do
    query |> Ecto.Query.where([user], user.last_login >= ^date)
  end

  def maybe_last_login_lte_filter(query, date) when is_nil(date) do
    query
  end

  def maybe_last_login_lte_filter(query, date) do
    query |> Ecto.Query.where([user], user.last_login <= ^date)
  end

  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, workspace_id) when is_nil(workspace_id) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.join(:inner, [user], workspace in ApiGateway.Models.Workspace,
      on: user.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([user, workspace], user)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_email_in_filter(filters[:email_in])
    |> maybe_full_name_contains_filter(filters[:full_name_contains])
    |> maybe_billing_status_filter(filters[:billing_status])
    |> maybe_last_login_filter(filters[:last_login])
    |> maybe_last_login_gte_filter(filters[:last_login_gte])
    |> maybe_last_login_lte_filter(filters[:last_login_lte])
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will raise"
  def get_user(user_id), do: Repo.get(ApiGateway.Models.User, user_id)

  def get_users(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.User |> add_query_filters(filters) |> Repo.all()
  end

  def create_user(data) when is_map(data) do
    %ApiGateway.Models.User{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_user(%{id: id, data: data}) do
    case get_user(id) do
      nil ->
        {:error, "Not found"}

      user ->
        user
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_user(id) do
    case get_user(id) do
      nil ->
        {:error, "Not found"}

      user ->
        Repo.delete(user)
    end
  end

  ####################
  # Utils #
  ####################
  # "switches out the password for the password hash in the changeset if it is available"
  defp maybe_put_pass_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Argon2.add_hash(password))
  end

  defp maybe_put_pass_hash(changeset), do: changeset
end
