defmodule ApiGateway.Models.AccountInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias __MODULE__

  # 7 days
  @invite_expiration_in_seconds 60 * 60 * 24 * 7

  schema "account_invitations" do
    field :email, :string
    field :invitation_token_hashed, :string
    field :accepted, :boolean

    timestamps()
  end

  @permitted_fields [
    :email,
    :invitation_token_hashed,
    :accepted
  ]
  @required_fields [
    :email,
    :invitation_token_hashed
  ]

  def changeset_create(%AccountInvitation{} = account_invitation, attrs \\ %{}) do
    account_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:invitation_token_hashed)
  end

  def changeset_update(%AccountInvitation{} = account_invitation, attrs \\ %{}) do
    account_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:invitation_token_hashed)
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

  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_accepted_filter(filters[:accepted])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "account_invitation_id must be a valid 'uuid' or an error will raise"
  def get_account_invitation(account_invitation_id) do
    Repo.get(AccountInvitation, account_invitation_id)
  end

  def get_account_invitation_by_email(email) do
    Repo.get_by(AccountInvitation, email: email)
  end

  def get_account_invitation_by_invitation_token_hashed(invitation_token_hashed) do
    Repo.get_by(AccountInvitation,
      invitation_token_hashed: invitation_token_hashed
    )
  end

  def get_account_invitations(filters \\ %{}) do
    IO.inspect(filters)

    AccountInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_account_invitation(%{email: email} = data) when is_binary(email) do
    {:ok, {invitation_token, invitation_token_hashed}} = create_invite_token()

    %AccountInvitation{}
    |> Map.put(:invitation_token_hashed, invitation_token_hashed)
    |> changeset_create(data)
    |> Repo.insert()

    {:ok, invitation_token}
  end

  def create_or_update_account_invitation(%{email: email} = data) when is_binary(email) do
    {:ok, {invitation_token, invitation_token_hashed}} = create_invite_token()

    case get_account_invitation_by_email(email) do
      nil ->
        %AccountInvitation{}
        |> Map.put(:invitation_token_hashed, invitation_token_hashed)
        |> changeset_create(data)

      account_invitation ->
        account_invitation
        |> changeset_update(%{accepted: false, invitation_token_hashed: invitation_token_hashed})

        # Post exists, let's use it
    end
    |> Repo.insert_or_update()

    {:ok, invitation_token}
  end

  def update_account_invitation(%{id: id, data: data}) do
    case get_account_invitation(id) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        account_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_account_invitation(%{email: email, data: data}) do
    case get_account_invitation_by_email(email) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        account_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_account_invitation(%{invitation_token_hashed: invitation_token_hashed, data: data}) do
    case get_account_invitation_by_invitation_token_hashed(invitation_token_hashed) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        account_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_account_invitation(id) do
    case get_account_invitation(id) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        Repo.delete(account_invitation)
    end
  end

  def delete_account_invitation_by_email(email) do
    case get_account_invitation_by_email(email) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        Repo.delete(account_invitation)
    end
  end

  defp create_invite_token() do
    invitation_token = Ecto.UUID.generate()

    invitation_token_hashed =
      invitation_token
      |> Argon2.hash_pwd_salt()

    {:ok, {invitation_token, invitation_token_hashed}}
  end

  def hash_and_token_match?(invite_token, hashed_invite_token) do
    Argon2.verify_pass(invite_token, hashed_invite_token)
  end

  @doc "checks the token with the provided email against the database and validates the invite age "
  def verify_invitation_token_with_db(email, token) when is_binary(email) and is_binary(token) do
    case get_account_invitation_by_email(email) do
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
