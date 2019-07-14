defmodule ApiGateway.Models.TeamMember do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "team_members" do
    field :role, :string

    belongs_to :user, ApiGateway.Models.User
    belongs_to :team, ApiGateway.Models.Team

    timestamps()
  end

  @permitted_fields [
    :role,
    :team_id,
    :user_id
  ]
  @required_fields_create [
    :role,
    :team_id,
    :user_id
  ]

  @team_member_roles [
    "MEMBER",
    "ADMIN"
  ]

  def get_team_member_roles do
    @team_member_roles
  end

  def changeset_create(%ApiGateway.Models.TeamMember{} = team_member, attrs \\ %{}) do
    team_member
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> validate_inclusion(:role, get_team_member_roles())
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.TeamMember{} = team_member, attrs \\ %{}) do
    team_member
    |> cast(attrs, @permitted_fields)
    |> validate_inclusion(:role, get_team_member_roles())
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
  end
end
