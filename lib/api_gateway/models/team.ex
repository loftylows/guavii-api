defmodule ApiGateway.Models.Team do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "teams" do
    field :title, :string
    field :description, :string

    has_many :members, ApiGateway.Models.TeamMember
    has_many :projects, ApiGateway.Models.Project
    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :workspace_id
  ]
  @required_fields_create [
    :title,
    :workspace_id
  ]

  def changeset_create(%ApiGateway.Models.Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:workspace_id)
  end

  def changeset_update(%ApiGateway.Models.Team{} = team, attrs \\ %{}) do
    team
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:workspace_id)
  end
end
