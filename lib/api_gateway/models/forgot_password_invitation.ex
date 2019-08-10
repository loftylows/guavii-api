defmodule ApiGateway.Models.ForgotPasswordInvitation do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "forgot_password_invitations" do
    field :token_hashed, :string
    field :accepted, :boolean

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
    |> Ecto.Query.join(:inner, [forgot_password_invitation], user in ApiGateway.Models.Account.User,
      on: forgot_password_invitation.user_id == ^user_id
    )
    |> Ecto.Query.select([forgot_password_invitation, user], forgot_password_invitation)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
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

  def get_forgot_password_invitations(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.ForgotPasswordInvitation |> add_query_filters(filters) |> Repo.all()
  end

  def create_forgot_password_invitation(data) when is_map(data) do
    %ApiGateway.Models.ForgotPasswordInvitation{}
    |> changeset_create(data)
    |> Repo.insert()
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

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_forgot_password_invitation(id) do
    case get_forgot_password_invitation(id) do
      nil ->
        {:error, "Not found"}

      forgot_password_invitation ->
        Repo.delete(forgot_password_invitation)
    end
  end
end
