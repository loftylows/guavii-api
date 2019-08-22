defmodule ApiGateway.Models.KanbanCardTodoList do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "kanban_card_todo_lists" do
    field :title, :string
    field :list_order_rank, :float

    has_many :todos, ApiGateway.Models.KanbanCardTodo
    belongs_to :kanban_card, ApiGateway.Models.KanbanCard

    timestamps()
  end

  @permitted_fields [
    :title,
    :list_order_rank,
    :kanban_card_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :kanban_card_id
  ]

  @permitted_fields_update [
    :title
  ]
  @required_fields_update [
    :title
  ]

  def changeset(
        %KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:kanban_card_id)
  end

  def changeset_update(
        %KanbanCardTodoList{} = kanban_card_todo_list,
        attrs \\ %{}
      ) do
    kanban_card_todo_list
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
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

  def add_query_filters(query, nil) do
    query
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
    do: Repo.get(KanbanCardTodoList, kanban_card_todo_list_id)

  def get_kanban_card_todo_lists(filters \\ %{}) do
    IO.inspect(filters)

    KanbanCardTodoList |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card_todo_list(data) when is_map(data) do
    rank =
      OrderedListHelpers.DB.get_new_item_insert_rank(
        "kanban_card_todo_lists",
        :kanban_card_id,
        data[:kanban_card_id]
      )

    %KanbanCardTodoList{}
    |> changeset(Map.put(data, :list_order_rank, rank))
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

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_kanban_card_todo_list(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
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

  ####################
  # Private helpers #
  ####################
  defp _update_with_position(%__MODULE__{} = item, prev, next, data) do
    full_data =
      data
      |> Map.put(:list_order_rank, OrderedListHelpers.get_insert_rank(prev, next))

    {:ok, item} =
      item
      |> changeset(full_data)
      |> Repo.update()

    case {prev, next} do
      # only item
      {nil, nil} ->
        {:ok, item}

      # last item
      {_prev, nil} ->
        {:ok, item}

      # first or between
      {_, _} ->
        case OrderedListHelpers.gap_acceptable?(prev, next) do
          true ->
            {:ok, item}

          false ->
            normalization_result =
              OrderedListHelpers.DB.normalize_list_order(
                "kanban_card_todo_lists",
                "list_order_rank",
                "kanban_card_id",
                item.kanban_card_id
              )

            normalized_list_id = item.kanban_card_id

            case normalization_result do
              {:ok, _} ->
                case ApiGateway.Repo.get(__MODULE__, item.id) do
                  nil ->
                    normalized_items =
                      get_kanban_card_todo_lists(%{kanban_card_id: normalized_list_id})

                    {{:list_order_normalized, normalized_list_id, normalized_items},
                     {:error, "Not found"}}

                  item ->
                    normalized_items =
                      get_kanban_card_todo_lists(%{kanban_card_id: normalized_list_id})

                    {{:list_order_normalized, normalized_list_id, normalized_items}, {:ok, item}}
                end

              {:error, _exception} ->
                Logger.debug(fn ->
                  {
                    "Ordered list rank normalization error",
                    [module: "#{__MODULE__}"]
                  }
                end)

                {:ok, item}
            end
        end
    end
  end
end
