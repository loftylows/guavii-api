defmodule ApiGateway.Models.SubListItemComment do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "sub_list_items" do
    field :content, :string

    belongs_to :sub_list_item, ApiGateway.Models.SubListItem
    belongs_to :by, ApiGateway.Models.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :content,
    :sub_list_item_id,
    :user_id
  ]
  @required_fields_create [
    :content,
    :sub_list_item_id,
    :user_id
  ]

  def changeset_create(
        %ApiGateway.Models.SubListItemComment{} = sub_list_item_comment,
        attrs \\ %{}
      ) do
    sub_list_item_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:sub_list_item_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(
        %ApiGateway.Models.SubListItemComment{} = sub_list_item_comment,
        attrs \\ %{}
      ) do
    sub_list_item_comment
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:sub_list_item_id)
    |> foreign_key_constraint(:user_id)
  end
end
