defmodule ApiGateway.Models.SubListItem do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "sub_list_items" do
    field :title, :string
    field :completed, :boolean, read_after_writes: true
    field :due_date, :utc_datetime
    field :list_order_rank, :float

    has_many :comments, ApiGateway.Models.SubListItemComment

    belongs_to :sub_list, ApiGateway.Models.SubList
    belongs_to :assigned_to, ApiGateway.Models.Account.User, foreign_key: :user_id
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :completed,
    :due_date,
    :list_order_rank,
    :user_id,
    :sub_list_id,
    :project_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :sub_list_id,
    :project_id
  ]

  @permitted_fields_update [
    :title,
    :description,
    :completed,
    :due_date,
    :user_id,
    :sub_list_id,
    :project_id
  ]
  @required_fields_update [
    :title,
    :sub_list_id,
    :project_id
  ]

  def changeset(%SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:sub_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank,
      greater_than: 0,
      less_than: OrderedListHelpers.get_largest_rank_possible()
    )
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:sub_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "sub_list_id must be a valid 'uuid' or an error will be raised"
  def maybe_sub_list_id_assoc_filter(query, sub_list_id) when is_nil(sub_list_id) do
    query
  end

  def maybe_sub_list_id_assoc_filter(query, sub_list_id) do
    query
    |> Ecto.Query.join(:inner, [sub_list_item], sub_list in ApiGateway.Models.SubList,
      on: sub_list_item.sub_list_id == ^sub_list_id
    )
    |> Ecto.Query.select([sub_list_item, sub_list], sub_list_item)
  end

  @doc "assigned_to_id must be a valid 'uuid' or an error will be raised"
  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) when is_nil(assigned_to_id) do
    query
  end

  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) do
    query
    |> Ecto.Query.join(:inner, [sub_list_item], user in ApiGateway.Models.Account.User,
      on: sub_list_item.user_id == ^assigned_to_id
    )
    |> Ecto.Query.select([sub_list_item, user], sub_list_item)
  end

  @doc "project_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_id_assoc_filter(query, project_id) when is_nil(project_id) do
    query
  end

  def maybe_project_id_assoc_filter(query, project_id) do
    query
    |> Ecto.Query.join(:inner, [sub_list_item], project in ApiGateway.Models.Project,
      on: sub_list_item.project_id == ^project_id
    )
    |> Ecto.Query.select([sub_list_item, project], sub_list_item)
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
    |> CommonFilterHelpers.maybe_due_date_filter(filters[:due_date])
    |> CommonFilterHelpers.maybe_due_date_gte_filter(filters[:due_date_gte])
    |> CommonFilterHelpers.maybe_due_date_lte_filter(filters[:due_date_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> CommonFilterHelpers.maybe_completed_filter(filters[:completed])
    |> maybe_assigned_to_id_assoc_filter(filters[:assigned_to])
    |> maybe_sub_list_id_assoc_filter(filters[:sub_list_id])
    |> maybe_project_id_assoc_filter(filters[:project_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_sub_list_item(id), do: Repo.get(SubListItem, id)

  def get_sub_list_items(filters \\ %{}) do
    IO.inspect(filters)

    SubListItem |> add_query_filters(filters) |> Repo.all()
  end

  def create_sub_list_item(data) when is_map(data) do
    insert_rank =
      OrderedListHelpers.DB.get_new_item_insert_rank(
        SubListItem,
        data[:sub_list_id],
        "list_order_rank"
      )

    %SubListItem{}
    |> changeset(Map.put(data, :list_order_rank, insert_rank))
    |> Repo.insert()
  end

  def update_sub_list_item(%{id: id, data: data}) do
    case get_sub_list_item(id) do
      nil ->
        {:error, "Not found"}

      sub_list_item ->
        sub_list_item
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_sub_list_item(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_sub_list_item(id) do
    case Repo.get(SubListItem, id) do
      nil ->
        {:error, "Not found"}

      sub_list_item ->
        Repo.delete(sub_list_item)
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
                "sub_list_items",
                "list_order_rank",
                "sub_list_id",
                item.sub_list_id
              )

            normalized_list_id = item.sub_list_id

            case normalization_result do
              {:ok, _} ->
                case ApiGateway.Repo.get(__MODULE__, item.id) do
                  nil ->
                    normalized_items = get_sub_list_items(%{sub_list_id: normalized_list_id})

                    {{:list_order_normalized, normalized_list_id, normalized_items},
                     {:error, "Not found"}}

                  item ->
                    normalized_items = get_sub_list_items(%{sub_list_id: normalized_list_id})
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
