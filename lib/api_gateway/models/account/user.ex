defmodule ApiGateway.Models.Account.User do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias Ecto.Multi
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
    field :workspace_role, :string
    field :billing_status, :string, read_after_writes: true
    field :password, :string, virtual: true
    field :password_hash, :string
    field :last_went_offline, :utc_datetime
    field :last_login, :utc_datetime

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
    :last_went_offline,
    :last_login
  ]

  @update_password_permitted_fields [
    :password
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

  @user_billing_status_map %{
    active: "ACTIVE",
    deactivated: "DEACTIVATED"
  }

  @spec get_user_billing_status_options :: [String.t()]
  def get_user_billing_status_options do
    @user_billing_status
  end

  @spec get_user_billing_status_options_map :: %{active: String.t(), deactivated: String.t()}
  def get_user_billing_status_options_map do
    @user_billing_status_map
  end

  @spec get_default_user_billing_status :: String.t()
  def get_default_user_billing_status do
    statuses = get_user_billing_status_options_map()

    statuses.active
  end

  @spec get_active_billing_status :: String.t()
  def get_active_billing_status do
    options = get_user_billing_status_options_map()

    options.active
  end

  @spec get_deactivated_billing_status :: String.t()
  def get_deactivated_billing_status do
    options = get_user_billing_status_options_map()

    options.deactivated
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

  def changeset_update_password(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @update_password_permitted_fields)
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
  @spec maybe_email_in_filter(Ecto.Query.t(), [String.t()]) :: Ecto.Query.t()
  def maybe_email_in_filter(query, list \\ [])

  def maybe_email_in_filter(query, list) when is_list(list) and length(list) > 0 do
    query |> Ecto.Query.where([p], p.email in ^list)
  end

  def maybe_email_in_filter(query, _) do
    query
  end

  @spec maybe_full_name_contains_filter(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  def maybe_full_name_contains_filter(query, field \\ "")

  def maybe_full_name_contains_filter(query, field) when is_binary(field) do
    query
    |> Ecto.Query.where([user], like(user.full_name, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_full_name_contains_filter(query, _) do
    query
  end

  @spec maybe_billing_status_filter(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  def maybe_billing_status_filter(query, nil) do
    query
  end

  def maybe_billing_status_filter(query, billing_status) do
    query |> Ecto.Query.where([user], user.billing_status == ^billing_status)
  end

  @spec maybe_last_login_filter(Ecto.Query.t(), any) :: Ecto.Query.t()
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
    |> Ecto.Query.where([user], user.workspace_id == ^workspace_id)
    |> Ecto.Query.select([workspace], workspace)
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

  def maybe_preload_workspace(query, nil) do
    query
  end

  def maybe_preload_workspace(query, false) do
    query
  end

  def maybe_preload_workspace(query, true) do
    query |> Ecto.Query.preload(:workspace)
  end

  def maybe_preload_workspace(query, _) do
    query
  end

  ####################
  # CRUD #
  ####################
  @doc "workspace_id must be a valid 'uuid' or an error will raise"
  def get_user(user_id, opts \\ []) do
    User
    |> maybe_preload_workspace(Keyword.get(opts, :preload_workspace, false))
    |> Repo.get(user_id)
  end

  @spec get_user_by_email_and_workspace_id(String.t(), String.t()) :: User.t()
  def get_user_by_email_and_workspace_id(email, workspace_id) do
    User
    |> Ecto.Query.where([user], email: ^email, workspace_id: ^workspace_id)
    |> Repo.one!()
  end

  @spec get_user_by_email_and_subdomain(String.t(), String.t()) :: User.t()
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
    User
    |> add_query_filters(filters)
    |> Repo.all()
  end

  def create_user(data) when is_map(data) do
    %User{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_user_password(
        %{id: id, data: %{old_password: old_password, new_password: new_password}},
        %User{} = current_user
      ) do
    (current_user.id == id)
    |> case do
      false ->
        {:error, :forbidden}

      true ->
        authenticate_by_email_password_and_workspace_id(
          current_user.email,
          old_password,
          current_user.workspace_id
        )
        |> case do
          {:error, _} ->
            {:error, :password_error}

          {:ok, user} ->
            user
            |> changeset_update_password(%{password: new_password})
            |> Repo.update()
        end
    end
  end

  def update_user_password_from_token(%{id: id, data: %{password: password}}) do
    case get_user(id) do
      nil ->
        {:error, "Not found"}

      user ->
        user
        |> changeset_update_password(%{password: password})
        |> Repo.update()
    end
  end

  def update_user(%{id: id, data: %{workspace_role: workspace_role} = data}) do
    # Only let billing status be set by next leg of this function
    data = Map.delete(data, :billing_status)

    roles = Workspace.get_workspace_roles_map()
    owner_role = roles.owner

    workspace_role
    |> case do
      ^owner_role ->
        {:error, "Forbidden"}

      _ ->
        case get_user(id) do
          nil ->
            {:error, "Not found"}

          user ->
            (user.workspace_role ==
               owner_role)
            |> case do
              true ->
                {:error, "Forbidden"}

              false ->
                user
                |> changeset_update(data)
                |> Repo.update()
            end
        end
    end
  end

  def update_user(%{id: id, data: %{billing_status: billing_status} = data}) do
    data = Map.delete(data, :workspace_role)

    case get_user(id, preload_workspace: true) do
      nil ->
        {:error, "Not found"}

      user ->
        options = get_user_billing_status_options_map()
        deactivated_status = options.deactivated

        (billing_status == get_active_billing_status() and
           user.billing_status ==
             deactivated_status)
        |> case do
          false ->
            user
            |> changeset_update(data)
            |> Repo.update()

          true ->
            active_member_count =
              Workspace.get_current_active_workspace_member_count(user.workspace_id)

            (active_member_count + 1 >=
               user.workspace.member_cap)
            |> case do
              true ->
                {:error,
                 "Workspace active member count reached. Increase workspace member cap to continue"}

              false ->
                user
                |> changeset_update(data)
                |> Repo.update()
            end
        end
    end
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

  @spec transfer_workspace_ownership_role(String.t(), String.t(), String.t()) ::
          {:ok, {User.t(), User.t()}} | {:error, String.t()} | {:error, :incorrect_password}
  def transfer_workspace_ownership_role(user_id_1, user_id_2, password) do
    user_1 = User.get_user(user_id_1)
    user_2 = User.get_user(user_id_2)
    roles = Workspace.get_workspace_roles_map()

    owner_role = roles.owner

    case {user_1, user_2} do
      {%User{workspace_role: ^owner_role}, %User{workspace_role: ^owner_role}} ->
        {:error, "User input error"}

      {%User{} = user_1, %User{} = user_2} ->
        if user_1.workspace_role != owner_role and user_2.workspace_role != owner_role do
          {:error, "User input error"}
        else
          Enum.find([user_1, user_2], fn user -> user.workspace_role == roles.owner end)
          |> case do
            nil ->
              {:error, "User input error"}

            owner ->
              authenticate_by_email_password_and_workspace_id(
                owner.email,
                password,
                owner.workspace_id
              )
              |> case do
                {:error, _} ->
                  {:error, :incorrect_password}

                _ ->
                  non_owner =
                    Enum.find([user_1, user_2], fn user -> user.workspace_role != roles.owner end)

                  switch_workspace_roles_multi(owner, non_owner)
                  |> Repo.transaction()
                  |> case do
                    {:ok, %{user_1: user_1, user_2: user_2}} ->
                      {:ok, {user_1, user_2}}

                    {:error, _, _, _} ->
                      {:error, "User input error"}
                  end
              end
          end
        end

      _ ->
        {:error, "User input error"}
    end
  end

  @spec switch_workspace_roles_multi(User.t(), User.t()) :: Ecto.Multi.t()
  defp switch_workspace_roles_multi(
         %User{workspace_role: workspaces_role_1} = owner,
         %User{workspace_role: _workspaces_role_2} = user
       ) do
    roles_map = Workspace.get_workspace_roles_map()

    Multi.new()
    |> Multi.update(:user_1, User.changeset_update(owner, %{workspace_role: roles_map.admin}))
    |> Multi.update(:user_2, User.changeset_update(user, %{workspace_role: workspaces_role_1}))
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

  @spec authenticate_by_email_password(
          String.t(),
          String.t(),
          String.t(),
          set_login_time: true | false
        ) ::
          {:ok, User.t()} | {:error, :unauthorized | :deactivated | String.t()}
  def authenticate_by_email_password(email, password, subdomain, opts \\ []) do
    case Workspace.get_workspace_by_subdomain(subdomain) do
      nil ->
        {:error, "Cannot find workspace"}

      workspace ->
        active_status = get_active_billing_status()
        deactivated_status = get_deactivated_billing_status()

        User
        |> Ecto.Query.where([u], u.email == ^email)
        |> Ecto.Query.where([u], u.workspace_id == ^workspace.id)
        |> Repo.one()
        |> case do
          %User{password_hash: password_hash, billing_status: ^active_status} = user ->
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

          %User{billing_status: ^deactivated_status} ->
            {:error, :deactivated}

          nil ->
            {:error, :unauthorized}

          _ ->
            {:error, :unauthorized}
        end
    end
  end

  @spec authenticate_by_email_password_and_workspace_id(
          String.t(),
          String.t(),
          String.t(),
          set_login_time: true | false
        ) ::
          {:ok, User.t()} | {:error, :unauthorized | :deactivated | String.t()}
  def authenticate_by_email_password_and_workspace_id(email, password, workspace_id, opts \\ []) do
    case Workspace.get_workspace(workspace_id) do
      nil ->
        {:error, "Cannot find workspace"}

      workspace ->
        active_status = get_active_billing_status()
        deactivated_status = get_deactivated_billing_status()

        User
        |> Ecto.Query.where([u], u.email == ^email)
        |> Ecto.Query.where([u], u.workspace_id == ^workspace.id)
        |> Repo.one()
        |> case do
          %User{password_hash: password_hash, billing_status: ^active_status} = user ->
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

          %User{billing_status: ^deactivated_status} ->
            {:error, :deactivated}

          nil ->
            {:error, :unauthorized}

          _ ->
            {:error, :unauthorized}
        end
    end
  end

  @spec set_last_login_now(String.t()) :: {:ok, User.t()} | {:error, any}
  def set_last_login_now(id) do
    update_user(%{id: id, data: %{last_login: DateTime.utc_now()}})
  end

  @spec set_last_went_offline_now(String.t()) :: {:ok, User.t()} | {:error, any}
  def set_last_went_offline_now(id) do
    update_user(%{id: id, data: %{last_went_offline: DateTime.utc_now()}})
  end

  ####################
  # Utils #
  ####################
  @spec maybe_put_pass_hash(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp maybe_put_pass_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Argon2.add_hash(password))
  end

  defp maybe_put_pass_hash(changeset) do
    changeset
  end
end
