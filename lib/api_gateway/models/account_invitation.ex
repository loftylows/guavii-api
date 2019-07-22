defmodule ApiGateway.Models.AccountInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

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
    :invitation_token_hashed,
    :accepted
  ]

  def changeset_create(%ApiGateway.Models.AccountInvitation{} = account_invitation, attrs \\ %{}) do
    account_invitation
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:invitation_token_hashed)
  end

  def changeset_update(%ApiGateway.Models.AccountInvitation{} = account_invitation, attrs \\ %{}) do
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
    Repo.get(ApiGateway.Models.AccountInvitation, account_invitation_id)
  end

  def get_account_invitation_by_email(email) do
    Repo.get_by(ApiGateway.Models.AccountInvitation, email: email)
  end

  def get_account_invitation_by_invitation_token_hashed(invitation_token_hashed) do
    Repo.get_by(ApiGateway.Models.AccountInvitation,
      invitation_token_hashed: invitation_token_hashed
    )
  end

  def get_account_invitations(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.AccountInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_account_invitation(data) when is_map(data) do
    %ApiGateway.Models.AccountInvitation{}
    |> changeset_create(data)
    |> Repo.insert()
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

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_account_invitation(id) do
    case get_account_invitation(id) do
      nil ->
        {:error, "Not found"}

      account_invitation ->
        Repo.delete(account_invitation)
    end
  end
end
