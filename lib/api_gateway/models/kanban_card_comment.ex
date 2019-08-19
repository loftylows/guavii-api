defmodule ApiGateway.Models.KanbanCardComment do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "kanban_card_comments" do
    field :content, :string
    field :edited, :string, read_after_writes: true

    belongs_to :kanban_card, ApiGateway.Models.KanbanCard
    belongs_to :by, ApiGateway.Models.Account.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :content,
    :edited,
    :kanban_card_id,
    :user_id
  ]
  @required_fields [
    :content,
    :kanban_card_id,
    :user_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanCardComment{} = kanban_card_comment, attrs \\ %{}) do
    kanban_card_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_card_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanCardComment{} = kanban_card_comment, attrs \\ %{}) do
    kanban_card_comment
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_card_id)
    |> foreign_key_constraint(:user_id)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_content_contains_filter(query, field \\ nil)

  def maybe_content_contains_filter(query, field) when is_binary(field) do
    query |> Ecto.Query.where([p], like(p.content, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_content_contains_filter(query, _) do
    query
  end

  def maybe_edited_filter(query, bool) when is_boolean(bool) do
    query |> Ecto.Query.where([p], p.edited == ^bool)
  end

  def maybe_edited_filter(query, _) do
    query
  end

  @doc "kanban_card_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) when is_nil(kanban_card_id) do
    query
  end

  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_comment], kanban_card in ApiGateway.Models.KanbanCard,
      on: kanban_card_comment.kanban_card_id == ^kanban_card_id
    )
    |> Ecto.Query.select([kanban_card_comment, kanban_card], kanban_card_comment)
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, user_id) when is_nil(user_id) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_comment], user in ApiGateway.Models.Account.User,
      on: kanban_card_comment.user_id == ^user_id
    )
    |> Ecto.Query.select([kanban_card_comment, user], kanban_card_comment)
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
    |> maybe_edited_filter(filters[:edited])
    |> maybe_content_contains_filter(filters[:content_contains])
    |> maybe_kanban_card_id_assoc_filter(filters[:kanban_card_id])
    |> maybe_user_id_assoc_filter(filters[:by_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "kanban_card_comment_id must be a valid 'uuid' or an error will be raised"
  def get_kanban_card_comment(kanban_card_comment_id),
    do: Repo.get(ApiGateway.Models.KanbanCardComment, kanban_card_comment_id)

  def get_kanban_card_comments(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.KanbanCardComment |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card_comment(data) when is_map(data) do
    %ApiGateway.Models.KanbanCardComment{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_kanban_card_comment(%{id: id, data: data}) do
    case get_kanban_card_comment(id) do
      nil ->
        {:error, "Not found"}

      kanban_card_comment ->
        case data[:content] && !kanban_card_comment.edited do
          true ->
            kanban_card_comment
            |> changeset_update(Map.put(data, :edited, true))
            |> Repo.update()

          false ->
            kanban_card_comment
            |> changeset_update(data)
            |> Repo.update()
        end
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_card_comment(id) do
    case Repo.get(ApiGateway.Models.KanbanCardComment, id) do
      nil ->
        {:error, "Not found"}

      kanban_card_comment ->
        Repo.delete(kanban_card_comment)
    end
  end
end
