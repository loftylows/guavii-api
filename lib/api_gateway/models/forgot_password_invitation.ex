defmodule ApiGateway.Models.ForgotPasswordInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.Account.User
  alias __MODULE__

  # 7 days
  @invite_expiration_in_seconds 60 * 60 * 24 * 7

  schema "forgot_password_invitations" do
    field :token_hashed, :string
    field :accepted, :boolean, read_after_writes: true

    belongs_to :user, ApiGateway.Models.Account.User

    timestamps()
  end

  @permitted_fields [
    :token_hashed,
    :accepted,
    :user_id
  ]
  @required_fields [
    :token_hashed,
    :user_id
  ]

  def changeset_create(
        %ApiGateway.Models.ForgotPasswordInvitation{} = forgot_password_invitation,
        attrs \\ %{}
      ) do
    forgot_password_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token_hashed)
  end

  def changeset_update(
        %ApiGateway.Models.ForgotPasswordInvitation{} = forgot_password_invitation,
        attrs \\ %{}
      ) do
    forgot_password_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token_hashed)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_accepted_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.where([p], p.accepted == ^bool)
  end

  def maybe_accepted_filter(query, _) do
    query
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, user_id) when is_nil(user_id) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.where([x], x.user_id == ^user_id)
  end

  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_accepted_filter(filters[:accepted])
    |> maybe_user_id_assoc_filter(filters[:user_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "forgot_password_invitation_id must be a valid 'uuid' or an error will raise"
  def get_forgot_password_invitation(forgot_password_invitation_id) do
    Repo.get(ApiGateway.Models.ForgotPasswordInvitation, forgot_password_invitation_id)
  end

  def get_forgot_password_invitation_by_token_hashed(token_hashed) do
    Repo.get_by(ApiGateway.Models.ForgotPasswordInvitation,
      token_hashed: token_hashed
    )
  end

  def get_forgot_password_invitation_by_user_id(user_id) do
    Repo.get_by(ApiGateway.Models.ForgotPasswordInvitation,
      user_id: user_id
    )
  end

  def get_forgot_password_invitations(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.ForgotPasswordInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_forgot_password_invitation(%{user_id: user_id} = data) when is_binary(user_id) do
    {:ok, {token, token_hashed}} = create_token()

    %ForgotPasswordInvitation{}
    |> Map.put(:token_hashed, token_hashed)
    |> changeset_create(data)
    |> Repo.insert()

    {:ok, token}
  end

  def create_or_update_forgot_password_invitation(%{user_id: user_id} = data)
      when is_binary(user_id) do
    {:ok, {token, token_hashed}} = create_token()

    case get_forgot_password_invitation_by_user_id(user_id) do
      nil ->
        %ForgotPasswordInvitation{}
        |> Map.put(:token_hashed, token_hashed)
        |> changeset_create(data)

      forgot_password_invitation ->
        forgot_password_invitation
        |> changeset_update(%{accepted: false, token_hashed: token_hashed})

        # Post exists, let's use it
    end
    |> Repo.insert_or_update()

    {:ok, token}
  end

  def update_forgot_password_invitation(%{id: id, data: data}) do
    case get_forgot_password_invitation(id) do
      nil ->
        {:error, "Not found"}

      forgot_password_invitation ->
        forgot_password_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_forgot_password_invitation(%{user_id: user_id, data: data}) do
    case get_forgot_password_invitation_by_user_id(user_id) do
      nil ->
        {:error, "Not found"}

      forgot_password_invitation ->
        forgot_password_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_forgot_password_invitation(id) do
    case get_forgot_password_invitation(id) do
      nil ->
        {:error, "Not found"}

      forgot_password_invitation ->
        Repo.delete(forgot_password_invitation)
    end
  end

  def delete_forgot_password_invitation_by_user_id(user_id) do
    case get_forgot_password_invitation_by_user_id(user_id) do
      nil ->
        {:error, "Not found"}

      forgot_password_invitation ->
        Repo.delete(forgot_password_invitation)
    end
  end

  defp create_token() do
    token = Ecto.UUID.generate()

    token_hashed =
      token
      |> Argon2.hash_pwd_salt()

    {:ok, {token, token_hashed}}
  end

  def reset_password_from_forgot_password_invite(password, user_id, token) do
    user_id
    |> verify_invitation_token_with_db(token)
    |> case do
      {:error, reason} ->
        {:error, :invitation, reason}

      {:ok, _} ->
        %{id: user_id, data: %{password: password}}
        |> User.update_user_password_from_token()
        |> case do
          {:error, reason_or_changeset_error} ->
            {:error, :user, reason_or_changeset_error}

          {:ok, user} ->
            ForgotPasswordInvitation.update_forgot_password_invitation(%{
              user_id: user_id,
              data: %{accepted: true}
            })
            |> case do
              {:error, _reason} ->
                {:error, :invitation, "Internal error"}

              {:ok, _} ->
                {:ok, user}
            end
        end
    end
  end

  ####################
  # Helper funcs #
  ####################
  @doc "checks the token with the provided email against the database and validates the invite age "
  def verify_invitation_token_with_db(user_id, token)
      when is_binary(user_id) and is_binary(token) do
    case get_forgot_password_invitation_by_user_id(user_id) do
      nil ->
        {:error, "Not found"}

      %__MODULE__{accepted: true} ->
        {:error, "Already accepted"}

      invite ->
        comparison =
          invite.inserted_at
          |> DateTime.add(get_invite_expiration_duration(), :second)
          |> DateTime.compare(DateTime.utc_now())

        case comparison do
          :gt ->
            {:ok, invite}

          :eq ->
            {:ok, invite}

          :lt ->
            {:error, "Invitation expired"}
        end
    end
  end

  @doc "invite valid duration in seconds"
  def get_invite_expiration_duration() do
    # 7 days
    @invite_expiration_in_seconds
  end
end
