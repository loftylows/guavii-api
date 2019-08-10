defmodule ApiGateway.Models.KanbanCard do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "kanban_cards" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date_range, ApiGateway.CustomEctoTypes.EctoDateRange
    field :list_order_rank, :float

    has_many :todo_lists, ApiGateway.Models.KanbanCardTodoList
    has_many :comments, ApiGateway.Models.KanbanCardComment

    many_to_many :activeLabels, ApiGateway.Models.KanbanLabel,
      join_through: "kanban_cards_active_labels"

    belongs_to :kanban_lane, ApiGateway.Models.KanbanLane
    belongs_to :project, ApiGateway.Models.Project
    belongs_to :assignedTo, ApiGateway.Models.Account.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :completed,
    :attachments,
    :list_order_rank,
    :due_date_range,
    :kanban_lane_id,
    :project_id,
    :user_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :kanban_lane_id,
    :project_id
  ]

  @permitted_fields_update [
    :title,
    :description,
    :completed,
    :attachments,
    :due_date_range,
    :project_id,
    :user_id
  ]
  @required_fields_update [
    :title,
    :project_id
  ]

  def changeset(%KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "kanban_lane_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_lane_id_assoc_filter(query, kanban_lane_id) when is_nil(kanban_lane_id) do
    query
  end

  def maybe_kanban_lane_id_assoc_filter(query, kanban_lane_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_todo], kanban_lane in ApiGateway.Models.KanbanLane,
      on: kanban_card_todo.kanban_lane_id == ^kanban_lane_id
    )
    |> Ecto.Query.select([kanban_card_todo, kanban_lane], kanban_card_todo)
  end

  @doc "assigned_to_id must be a valid 'uuid' or an error will be raised"
  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) when is_nil(assigned_to_id) do
    query
  end

  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card], user in ApiGateway.Models.Account.User,
      on: kanban_card.user_id == ^assigned_to_id
    )
    |> Ecto.Query.select([kanban_card, user], kanban_card)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> CommonFilterHelpers.maybe_completed_filter(filters[:completed])
    |> CommonFilterHelpers.maybe_project_id_assoc_filter(filters[:project_id])
    |> maybe_kanban_lane_id_assoc_filter(filters[:kanban_lane_id])
    |> maybe_assigned_to_id_assoc_filter(filters[:assigned_to])
  end

  ####################
  # Queries #
  ####################
  @doc "kanban_card_id must be a valid 'uuid' or an error will raise"
  def get_kanban_card(kanban_card_id), do: Repo.get(KanbanCard, kanban_card_id)

  def get_kanban_cards(filters \\ %{}) do
    IO.inspect(filters)

    KanbanCard |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card(data) when is_map(data) do
    %KanbanCard{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update_kanban_card(%{id: id, data: data}) do
    case get_kanban_card(id) do
      nil ->
        {:error, "Not found"}

      kanban_card ->
        kanban_card
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_kanban_card(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_card(id) do
    case Repo.get(KanbanCard, id) do
      nil ->
        {:error, "Not found"}

      kanban_card ->
        Repo.delete(kanban_card)
    end
  end

  ####################
  # Private helpers #
  ####################
  defp _update_with_position(%KanbanCard{} = item, prev, next, data) do
    full_data =
      data
      |> Map.put(:list_order_rank, OrderedListHelpers.get_insert_rank(prev, next))

    item =
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
                "kanban_cards",
                "list_order_rank",
                "kanban_lane_id",
                item.kanban_lane_id
              )

            normalized_list_id = item.kanban_lane_id

            case normalization_result do
              {:ok, _} ->
                case ApiGateway.Repo.get(__MODULE__, item.id) do
                  nil ->
                    {{:list_order_normalized, normalized_list_id}, {:error, "Not found"}}

                  item ->
                    {{:list_order_normalized, normalized_list_id}, {:ok, item}}
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
