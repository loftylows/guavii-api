defmodule ApiGateway.Models.SubListItemComment do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "sub_list_item_comments" do
    field :content, :string
    field :edited, :boolean

    belongs_to :sub_list_item, ApiGateway.Models.SubListItem
    belongs_to :by, ApiGateway.Models.Account.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :content,
    :sub_list_item_id,
    :user_id,
    :edited
  ]
  @required_fields [
    :content,
    :sub_list_item_id
  ]

  def changeset_create(
        %ApiGateway.Models.SubListItemComment{} = sub_list_item_comment,
        attrs \\ %{}
      ) do
    sub_list_item_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:sub_list_item_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(
        %ApiGateway.Models.SubListItemComment{} = sub_list_item_comment,
        attrs \\ %{}
      ) do
    sub_list_item_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:sub_list_item_id)
    |> foreign_key_constraint(:user_id)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_content_contains_filter(query, words \\ nil)

  def maybe_content_contains_filter(query, words) when is_binary(words) do
    query
    |> Ecto.Query.where([p], like(p.content, ^"%#{String.replace(words, "%", "\\%")}%"))
  end

  def maybe_content_contains_filter(query, _) do
    query
  end

  def maybe_edited_filter(query, edited \\ nil)

  def maybe_edited_filter(query, edited) when is_nil(edited) do
    query
  end

  def maybe_edited_filter(query, edited) when is_boolean(edited) do
    query |> Ecto.Query.where([kanban_lane], kanban_lane.edited == ^edited)
  end

  @doc "sub_list_item_id must be a valid 'uuid' or an error will be raised"
  def maybe_sub_list_item_id_assoc_filter(query, sub_list_item_id)
      when is_nil(sub_list_item_id) do
    query
  end

  def maybe_sub_list_item_id_assoc_filter(query, sub_list_item_id) do
    query
    |> Ecto.Query.join(
      :inner,
      [sub_list_item_comment],
      sub_list_item in ApiGateway.Models.SubListItem,
      on: sub_list_item_comment.sub_list_item_id == ^sub_list_item_id
    )
    |> Ecto.Query.select([sub_list_item_comment, sub_list_item], sub_list_item_comment)
  end

  @doc "commenter_id must be a valid 'uuid' or an error will be raised"
  def maybe_commenter_id_assoc_filter(query, commenter_id) when is_nil(commenter_id) do
    query
  end

  def maybe_commenter_id_assoc_filter(query, commenter_id) do
    query
    |> Ecto.Query.join(:inner, [sub_list_item_comment], user in ApiGateway.Models.Account.User,
      on: sub_list_item_comment.user_id == ^commenter_id
    )
    |> Ecto.Query.select([sub_list_item_comment, user], sub_list_item_comment)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_content_contains_filter(filters[:content_contains])
    |> maybe_edited_filter(filters[:edited])
    |> maybe_sub_list_item_id_assoc_filter(filters[:sub_list_item_id])
    |> maybe_commenter_id_assoc_filter(filters[:by_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_sub_list_item_comment(id), do: Repo.get(ApiGateway.Models.SubListItemComment, id)

  def get_sub_list_item_comments(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.SubListItemComment |> add_query_filters(filters) |> Repo.all()
  end

  def create_sub_list_item_comment(data) when is_map(data) do
    %ApiGateway.Models.SubListItemComment{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_sub_list_item_comment(%{id: id, data: data}) do
    case get_sub_list_item_comment(id) do
      nil ->
        {:error, "Not found"}

      sub_list_item_comment ->
        case data[:content] && !sub_list_item_comment.edited do
          true ->
            sub_list_item_comment
            |> changeset_update(Map.put(data, :edited, true))
            |> Repo.update()

          false ->
            sub_list_item_comment
            |> changeset_update(data)
            |> Repo.update()
        end
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_sub_list_item_comment(id) do
    case Repo.get(ApiGateway.Models.SubListItemComment, id) do
      nil ->
        {:error, "Not found"}

      sub_list_item_comment ->
        Repo.delete(sub_list_item_comment)
    end
  end
end
