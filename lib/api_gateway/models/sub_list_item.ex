defmodule ApiGateway.Models.SubListItem do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  schema "sub_list_items" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date_range, ApiGateway.CustomEctoTypes.EctoDateRange

    has_many :comments, ApiGateway.Models.SubListItemComment

    belongs_to :sub_list, ApiGateway.Models.SubList
    belongs_to :assigned_to, ApiGateway.Models.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :completed,
    :attachments,
    :due_date_range
  ]
  @required_fields_create [
    :title,
    :sub_list_id
  ]

  def changeset_create(%ApiGateway.Models.SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:sub_list_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:sub_list_id)
    |> foreign_key_constraint(:user_id)
  end
end
