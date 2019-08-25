defmodule ApiGateway.Models.KanbanLane do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "kanban_lanes" do
    field :title, :string
    field :lane_color, :string
    field :list_order_rank, :float

    has_many :cards, ApiGateway.Models.KanbanCard
    belongs_to :kanban_board, ApiGateway.Models.KanbanBoard

    timestamps()
  end

  @permitted_fields [
    :title,
    :lane_color,
    :list_order_rank,
    :kanban_board_id
  ]
  @required_fields [
    :title,
    :lane_color,
    :list_order_rank,
    :kanban_board_id
  ]

  @permitted_fields_update [
    :title,
    :lane_color
  ]
  @required_fields_update [
    :title,
    :lane_color
  ]

  def changeset(%__MODULE__{} = kanban_lane, attrs \\ %{}) do
    kanban_lane
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:kanban_board_id)
  end

  def changeset_update(%__MODULE__{} = kanban_lane, attrs \\ %{}) do
    kanban_lane
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:kanban_board_id)
  end

  ####################
  # Query helpers #
  ####################

  def maybe_lane_color_filter(query, nil) do
    query
  end

  def maybe_lane_color_filter(query, lane_color) do
    query |> Ecto.Query.where([kanban_lane], kanban_lane.lane_color == ^lane_color)
  end

  @doc "kanban_board_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_board_id_assoc_filter(query, kanban_board_id) when is_nil(kanban_board_id) do
    query
  end

  def maybe_kanban_board_id_assoc_filter(query, kanban_board_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_lane], kanban_board in ApiGateway.Models.KanbanBoard,
      on: kanban_lane.kanban_board_id == ^kanban_board_id
    )
    |> Ecto.Query.select([kanban_lane, kanban_board], kanban_lane)
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
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_lane_color_filter(filters[:lane_color])
    |> maybe_kanban_board_id_assoc_filter(filters[:kanban_board_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_kanban_lane(id), do: Repo.get(KanbanLane, id)

  def get_kanban_lanes(filters \\ %{}) do
    IO.inspect(filters)

    KanbanLane |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_lane(data) when is_map(data) do
    rank =
      OrderedListHelpers.DB.get_new_item_insert_rank(
        "kanban_lanes",
        :kanban_board_id,
        data[:kanban_board_id]
      )

    %KanbanLane{}
    |> changeset(Map.put(data, :list_order_rank, rank))
    |> Repo.insert()
  end

  def update_kanban_lane(%{id: id, data: data}) do
    case get_kanban_lane(id) do
      nil ->
        {:error, "Not found"}

      kanban_lane ->
        kanban_lane
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_kanban_lane(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_lane(id) do
    case Repo.get(KanbanLane, id) do
      nil ->
        {:error, "Not found"}

      kanban_lane ->
        Repo.delete(kanban_lane)
    end
  end

  ####################
  # Private helpers #
  ####################
  defp _update_with_position(%KanbanLane{} = item, prev, next, data) do
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
                "kanban_lanes",
                "list_order_rank",
                "kanban_board_id",
                item.kanban_board_id
              )

            normalized_list_id = item.kanban_board_id

            case normalization_result do
              {:ok, _} ->
                case ApiGateway.Repo.get(__MODULE__, item.id) do
                  nil ->
                    normalized_items = get_kanban_lanes(%{kanban_board_id: normalized_list_id})

                    {{:list_order_normalized, normalized_list_id, normalized_items},
                     {:error, "Not found"}}

                  item ->
                    normalized_items = get_kanban_lanes(%{kanban_board_id: normalized_list_id})
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
