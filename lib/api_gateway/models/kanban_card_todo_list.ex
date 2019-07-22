defmodule ApiGateway.Models.KanbanCardTodoList do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "kanban_card_todo_lists" do
    field :title, :string

    has_many :todos, ApiGateway.Models.KanbanCardTodo
    belongs_to :kanban_card, ApiGateway.Models.KanbanCard

    timestamps()
  end

  @permitted_fields [
    :title,
    :kanban_card_id
  ]
  @required_fields [
    :title,
    :kanban_card_id
  ]

  def changeset_create(
        %ApiGateway.Models.KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_card_id)
  end

  def changeset_update(
        %ApiGateway.Models.KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_card_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "kanban_card_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) when is_nil(kanban_card_id) do
    query
  end

  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) do
    query
    |> Ecto.Query.join(
      :inner,
      [kanban_card_todo_list],
      kanban_card in ApiGateway.Models.KanbanCard,
      on: kanban_card_todo_list.kanban_card_id == ^kanban_card_id
    )
    |> Ecto.Query.select([kanban_card_todo_list, kanban_card], kanban_card_todo_list)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> maybe_kanban_card_id_assoc_filter(filters[:kanban_card_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "kanban_card_todo_list_id must be a valid 'uuid' or an error will be raised"
  def get_kanban_card_todo_list(kanban_card_todo_list_id),
    do: Repo.get(ApiGateway.Models.KanbanCardTodoList, kanban_card_todo_list_id)

  def get_kanban_card_todo_lists(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.KanbanCardTodoList |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card_todo_list(data) when is_map(data) do
    %ApiGateway.Models.KanbanCardTodoList{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_kanban_card_todo_list(%{id: id, data: data}) do
    case get_kanban_card_todo_list(id) do
      nil ->
        {:error, "Not found"}

      kanban_card_todo_list ->
        kanban_card_todo_list
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_card_todo_list(id) do
    case Repo.get(ApiGateway.Models.KanbanCardTodoList, id) do
      nil ->
        {:error, "Not found"}

      kanban_card_todo_list ->
        Repo.delete(kanban_card_todo_list)
    end
  end
end
