defmodule ApiGateway.Models.WorkspaceInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.Account.User
  alias ApiGateway.Models.Workspace
  alias __MODULE__

  # 7 days
  @invite_expiration_in_seconds 60 * 60 * 24 * 7
  @valid_workspace_roles Workspace.get_assignable_workspace_roles()

  schema "workspace_invitations" do
    field :email, :string
    field :invitation_token_hashed, :string
    field :accepted, :boolean, read_after_writes: true
    field :workspace_role, :string, read_after_writes: true

    belongs_to :workspace, ApiGateway.Models.Workspace
    belongs_to :invited_by, ApiGateway.Models.Account.User

    timestamps()
  end

  @permitted_fields [
    :email,
    :invitation_token_hashed,
    :accepted,
    :workspace_role,
    :workspace_id,
    :invited_by_id
  ]
  @required_fields_create [
    :email,
    :invitation_token_hashed,
    :workspace_id
  ]

  def changeset_create(
        %ApiGateway.Models.WorkspaceInvitation{} = workspace_invitation,
        attrs \\ %{}
      ) do
    workspace_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:workspace_role, @valid_workspace_roles)
    |> foreign_key_constraint(:invited_by_id)
    |> foreign_key_constraint(:workspace_id)
    |> unique_constraint(:email)
    |> unique_constraint(:invitation_token_hashed)
  end

  def changeset_update(
        %ApiGateway.Models.WorkspaceInvitation{} = workspace_invitation,
        attrs \\ %{}
      ) do
    workspace_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_inclusion(:workspace_role, @valid_workspace_roles)
    |> foreign_key_constraint(:invited_by_id)
    |> foreign_key_constraint(:workspace_id)
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

  @doc "team_id must be a valid 'uuid' or an error will be raised"
  def maybe_team_id_assoc_filter(query, nil) do
    query
  end

  def maybe_team_id_assoc_filter(query, team_id) do
    query
    |> Ecto.Query.where([p], p.team_id == ^team_id)
  end

  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, nil) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.where([p], p.workspace_id == ^workspace_id)
  end

  def maybe_invited_by_id_assoc_filter(query, nil) do
    query
  end

  def maybe_invited_by_id_assoc_filter(query, invited_by_id) do
    query
    |> Ecto.Query.where([p], p.invited_by_id == ^invited_by_id)
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
    |> maybe_team_id_assoc_filter(filters[:team_id])
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
    |> maybe_invited_by_id_assoc_filter(filters[:invited_by_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "workspace_invitation_id must be a valid 'uuid' or an error will raise"
  def get_workspace_invitation(workspace_invitation_id) do
    Repo.get(ApiGateway.Models.WorkspaceInvitation, workspace_invitation_id)
  end

  def get_workspace_invitation_by_email(email) do
    Repo.get_by(ApiGateway.Models.WorkspaceInvitation, email: email)
  end

  def get_workspace_invitation_by_invitation_token_hashed(invitation_token_hashed) do
    Repo.get_by(ApiGateway.Models.WorkspaceInvitation,
      invitation_token_hashed: invitation_token_hashed
    )
  end

  def get_workspace_invitations(filters \\ %{}) do
    ApiGateway.Models.WorkspaceInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_workspace_invitation(data, %User{id: current_user_id}) when is_map(data) do
    %ApiGateway.Models.WorkspaceInvitation{}
    |> changeset_create(Map.put(data, :invited_by_id, current_user_id))
    |> Repo.insert()
  end

  def create_or_update_workspace_invitation(%{email: email} = data, %User{} = user)
      when is_binary(email) do
    {:ok, {invitation_token, invitation_token_hashed}} = create_invite_token()

    case get_workspace_invitation_by_email(email) do
      nil ->
        %WorkspaceInvitation{}
        |> Map.put(:invitation_token_hashed, invitation_token_hashed)
        |> Map.put(:invited_by_id, user.id)
        |> changeset_create(data)

      workspace_invitation ->
        data = %{
          accepted: false,
          invitation_token_hashed: invitation_token_hashed,
          invited_by_id: user.id
        }

        workspace_invitation
        |> changeset_update(data)
    end
    |> Repo.insert_or_update()

    {:ok, invitation_token}
  end

  def create_or_update_workspace_invitations(
        invitation_info_items,
        %User{} = user
      )
      when is_list(invitation_info_items) do
    invitation_tokens_with_emails_and_names =
      for %{email: email, name: name} = invite_info <- invitation_info_items do
        {:ok, {invitation_token, invitation_token_hashed}} = create_invite_token()

        workspace_role =
          Map.get(invite_info, :workspace_role, Workspace.get_default_workspace_role())

        case get_workspace_invitation_by_email(email) do
          nil ->
            %WorkspaceInvitation{
              email: email,
              invitation_token_hashed: invitation_token_hashed,
              invited_by_id: user.id,
              workspace_role: workspace_role,
              workspace_id: user.workspace_id
            }
            |> changeset_create()

          workspace_invitation ->
            data = %{
              accepted: false,
              workspace_role: workspace_role,
              invitation_token_hashed: invitation_token_hashed,
              invited_by_id: user.id
            }

            workspace_invitation
            |> changeset_update(data)
        end
        |> Repo.insert_or_update()

        %{
          email: email,
          name: name,
          workspace_role: workspace_role,
          invitation_token: invitation_token
        }
      end

    {:ok, invitation_tokens_with_emails_and_names}
  end

  def update_workspace_invitation(%{id: id, data: data}) do
    case get_workspace_invitation(id) do
      nil ->
        {:error, "Not found"}

      workspace_invitation ->
        workspace_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_workspace_invitation(%{email: email, data: data}) do
    case get_workspace_invitation_by_email(email) do
      nil ->
        {:error, "Not found"}

      workspace_invitation ->
        workspace_invitation
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_workspace_invitation(id) do
    case get_workspace_invitation(id) do
      nil ->
        {:error, "Not found"}

      workspace_invitation ->
        Repo.delete(workspace_invitation)
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
    case get_workspace_invitation_by_email(email) do
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
