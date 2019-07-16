defmodule ApiGateway.Models.KanbanCardComment do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "kanban_card_comments" do
    field :content, :string
    field :edited, :string

    belongs_to :kanban_card, ApiGateway.Models.KanbanCard
    belongs_to :by, ApiGateway.Models.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :content,
    :edited,
    :kanban_card_id,
    :user_id
  ]
  @required_fields_create [
    :content,
    :kanban_card_id,
    :user_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanCardComment{} = kanban_card_comment, attrs \\ %{}) do
    kanban_card_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_card_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanCardComment{} = kanban_card_comment, attrs \\ %{}) do
    kanban_card_comment
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_card_id)
    |> foreign_key_constraint(:user_id)
  end
end
