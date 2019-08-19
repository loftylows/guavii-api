defmodule ApiGateway.Models.Account.User do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.Workspace
  alias __MODULE__

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
    field :billing_status, :string, read_after_writes: true
    field :password, :string, virtual: true
    field :password_hash, :string

    embeds_one :time_zone, TimeZone, on_replace: :update do
      field :offset, :string
      field :name, :string
    end

    has_many :team_members, ApiGateway.Models.TeamMember
    belongs_to :workspace, Workspace

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
    :billing_status,
    :workspace_id,
    :password,
    :last_login
  ]
  @required_fields_create [
    :full_name,
    :workspace_role,
    :workspace_id,
    :password
  ]

  @required_fields_update [
    :full_name,
    :workspace_role,
    :workspace_id
  ]

  @time_zone_permitted_fields [
    :offset,
    :name
  ]

  @user_billing_status [
    "ACTIVE",
    "DEACTIVATED"
  ]

  def get_user_billing_status_options do
    @user_billing_status
  end

  def changeset_create(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:time_zone, with: &time_zone_changeset/2)
    |> validate_required(@required_fields_create)
    |> validate_length(:password, min: 8, max: 100, message: "should be at least 8 characters")
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, Workspace.get_workspace_roles())
    |> validate_inclusion(:billing_status, get_user_billing_status_options())
    |> maybe_put_pass_hash()
    |> foreign_key_constraint(:workspace_id)
    |> unique_constraint(:email, name: :unique_workspace_email_index)
  end

  def changeset_update(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:time_zone, with: &time_zone_changeset/2)
    |> validate_required(@required_fields_update)
    |> validate_format(:email, Utils.Regex.get_email_regex())
    |> validate_inclusion(:workspace_role, Workspace.get_workspace_roles())
    |> validate_inclusion(:billing_status, get_user_billing_status_options())
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

  def maybe_billing_status_filter(query, nil) do
    query
  end

  def maybe_billing_status_filter(query, billing_status) do
    query |> Ecto.Query.where([user], user.billing_status == ^billing_status)
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
  def maybe_workspace_id_assoc_filter(query, nil) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.join(:inner, [user], workspace in Workspace,
      on: user.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([user, workspace], user)
  end

  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_first_filter(filters[:first])
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
  def get_user(user_id) do
    User
    |> Repo.get(user_id)
  end

  def get_user_by_email_and_workspace_id(email, workspace_id) do
    User
    |> Ecto.Query.where([user], email: ^email, workspace_id: ^workspace_id)
    |> Repo.one!()
  end

  def get_user_by_email_and_subdomain(email, subdomain) do
    case Workspace.get_workspace_by_subdomain(subdomain) do
      nil ->
        nil

      workspace ->
        User
        |> Ecto.Query.where([user], email: ^email, workspace_id: ^workspace.id)
        |> Repo.one!()
    end
  end

  @spec get_users(map) :: [User.t()]
  def get_users(filters \\ %{}) do
    IO.inspect(filters)

    User
    |> add_query_filters(filters)
    |> Repo.all()
  end

  def create_user(data) when is_map(data) do
    %User{}
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

  def authenticate_by_email_password(email, password, subdomain, opts \\ []) do
    case Workspace.get_workspace_by_subdomain(subdomain) do
      nil ->
        {:error, "Cannot find workspace"}

      workspace ->
        User
        |> Ecto.Query.where([u], u.email == ^email)
        |> Ecto.Query.where([u], u.workspace_id == ^workspace.id)
        |> Repo.one()
        |> case do
          %User{password_hash: password_hash} = user ->
            password
            |> Argon2.verify_pass(password_hash)
            |> case do
              false ->
                {:error, :unauthorized}

              true ->
                if Keyword.get(opts, :set_login_time, false) do
                  update_user(%{id: user.id, data: %{last_login: DateTime.utc_now()}})
                else
                  {:ok, user}
                end
            end

          nil ->
            {:error, :unauthorized}
        end
    end
  end

  def set_last_login_now(id) do
    update_user(%{id: id, data: %{last_login: DateTime.utc_now()}})
  end

  ####################
  # Utils #
  ####################
  defp maybe_put_pass_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Argon2.add_hash(password))
  end

  defp maybe_put_pass_hash(changeset) do
    changeset
  end
end
