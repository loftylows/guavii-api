defmodule ApiGateway.Models.WorkspaceInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "workspace_invitations" do
    field :email, :string
    field :invitation_token_hashed, :string
    field :accepted, :boolean

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :email,
    :invitation_token_hashed,
    :accepted,
    :workspace_id
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

  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, workspace_id) when is_nil(workspace_id) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.join(:inner, [workspace_invitation], workspace in ApiGateway.Models.Workspace,
      on: workspace_invitation.workspace_id == ^workspace_id
    )
    |> Ecto.Query.select([workspace_invitation, workspace], workspace_invitation)
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
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "account_invitation_id must be a valid 'uuid' or an error will raise"
  def get_workspace_invitation(account_invitation_id) do
    Repo.get(ApiGateway.Models.WorkspaceInvitation, account_invitation_id)
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
    IO.inspect(filters)

    ApiGateway.Models.WorkspaceInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_account_invitation(data) when is_map(data) do
    %ApiGateway.Models.WorkspaceInvitation{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_account_invitation(%{id: id, data: data}) do
    case get_workspace_invitation(id) do
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
    case get_workspace_invitation(id) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        Repo.delete(account_invitation)
    end
  end
end
