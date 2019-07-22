defmodule ApiGateway.Models.FindMyWorkspacesInvitation do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

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
    Repo.get(ApiGateway.Models.FindMyWorkspacesInvitation, find_my_workspaces_invitation_id)
  end

  def get_find_my_workspaces_invitation_by_email(email) do
    Repo.get_by(ApiGateway.Models.FindMyWorkspacesInvitation, email: email)
  end

  def get_find_my_workspaces_invitation_by_token_hashed(token_hashed) do
    Repo.get_by(ApiGateway.Models.FindMyWorkspacesInvitation,
      token_hashed: token_hashed
    )
  end

  def get_find_my_workspaces_invitations(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.FindMyWorkspacesInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_find_my_workspaces_invitation(data) when is_map(data) do
    %ApiGateway.Models.FindMyWorkspacesInvitation{}
    |> changeset_create(data)
    |> Repo.insert()
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
end
