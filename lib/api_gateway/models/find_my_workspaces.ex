defmodule ApiGateway.Models.FindMyWorkspacesInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.Workspace
  alias ApiGateway.Models.Account.User
  alias __MODULE__

  # 7 days
  @invite_expiration_in_seconds 60 * 60 * 24 * 7

  schema "find_my_workspaces_invitations" do
    field :email, :string
    field :token_hashed, :string

    timestamps()
  end

  @permitted_fields [
    :email,
    :token_hashed
  ]
  @required_fields [
    :email,
    :token_hashed
  ]

  def changeset_create(
        %ApiGateway.Models.FindMyWorkspacesInvitation{} = find_my_workspaces_invitation,
        attrs \\ %{}
      ) do
    find_my_workspaces_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:token_hashed)
  end

  def changeset_update(
        %ApiGateway.Models.FindMyWorkspacesInvitation{} = find_my_workspaces_invitation,
        attrs \\ %{}
      ) do
    find_my_workspaces_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:token_hashed)
  end

  ####################
  # Query helpers #
  ####################
  def add_query_filters(query, nil) do
    query
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will raise"
  def get_find_my_workspaces_invitation(find_my_workspaces_invitation_id) do
    Repo.get(FindMyWorkspacesInvitation, find_my_workspaces_invitation_id)
  end

  def get_find_my_workspaces_invitation_by_email(email) do
    Repo.get_by(FindMyWorkspacesInvitation, email: email)
  end

  def get_find_my_workspaces_invitation_by_token_hashed(token_hashed) do
    Repo.get_by(FindMyWorkspacesInvitation,
      token_hashed: token_hashed
    )
  end

  def get_find_my_workspaces_invitations(filters \\ %{}) do
    IO.inspect(filters)

    FindMyWorkspacesInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_find_my_workspaces_invitation(data) when is_map(data) do
    {:ok, {token, token_hashed}} = create_token()

    %FindMyWorkspacesInvitation{}
    |> Map.put(:token_hashed, token_hashed)
    |> changeset_create(data)
    |> Repo.insert()

    {:ok, token}
  end

  def create_or_update_find_my_workspaces_invitation(%{email: email} = data)
      when is_binary(email) do
    {:ok, {token, token_hashed}} = create_token()

    case get_find_my_workspaces_invitation_by_email(email) do
      nil ->
        %FindMyWorkspacesInvitation{}
        |> Map.put(:token_hashed, token_hashed)
        |> changeset_create(data)

      find_my_workspaces_invitation ->
        find_my_workspaces_invitation
        |> changeset_update(%{token_hashed: token_hashed})

        # Post exists, let's use it
    end
    |> Repo.insert_or_update()

    {:ok, token}
  end

  def update_find_my_workspaces_invitation(%{id: id, data: data}) do
    case get_find_my_workspaces_invitation(id) do
      nil ->
        {:error, "Not found"}

      find_my_workspaces_invitation ->
        find_my_workspaces_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_find_my_workspaces_invitation(id) do
    case get_find_my_workspaces_invitation(id) do
      nil ->
        {:error, "Not found"}

      find_my_workspaces_invitation ->
        Repo.delete(find_my_workspaces_invitation)
    end
  end

  @spec find_my_workspaces(String.t(), String.t()) ::
          [FindMyWorkspacesInvitation.t()] | {:error, String.t()}
  def find_my_workspaces(base_64_url_encoded_email, token) do
    base_64_url_encoded_email
    |> Base.url_decode64(padding: false)
    |> case do
      :error ->
        {:error, "User input error"}

      {:ok, email} ->
        email
        |> verify_invitation_token_with_db(token)
        |> case do
          {:error, _} = error ->
            error

          {:ok, _} ->
            find_workspaces_by_connected_user_email(email)
        end
    end
  end

  def find_workspaces_by_connected_user_email(email) when is_binary(email) do
    query =
      from w in Workspace,
        join: u in User,
        where: u.email == ^email and u.workspace_id == w.id,
        select: w

    Repo.all(query)
  end

  defp create_token() do
    token = Ecto.UUID.generate()

    token_hashed =
      token
      |> Argon2.hash_pwd_salt()

    {:ok, {token, token_hashed}}
  end

  ####################
  # Helper funcs #
  ####################
  @doc "checks the token with the provided email against the database and validates the invite age "
  def verify_invitation_token_with_db(email, token)
      when is_binary(email) and is_binary(token) do
    case get_find_my_workspaces_invitation_by_email(email) do
      nil ->
        {:error, "Not found"}

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
    @invite_expiration_in_seconds
  end
end
