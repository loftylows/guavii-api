defmodule ApiGateway.Models.ProjectTodoList do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "project_todo_lists" do
    field :title, :string
    field :list_order_rank, :float

    has_many :todos, ApiGateway.Models.ProjectTodo

    belongs_to :project, ApiGateway.Models.Project
    belongs_to :project_lists_board, ApiGateway.Models.ProjectListsBoard

    timestamps()
  end

  @permitted_fields [
    :title,
    :list_order_rank,
    :project_id,
    :project_lists_board_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :project_id,
    :project_lists_board_id
  ]

  @permitted_fields_update [
    :title,
    :project_id
  ]
  @required_fields_update [
    :title,
    :project_id
  ]

  def changeset(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:project_lists_board_id)
  end

  def changeset_update(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:project_lists_board_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "project_lists_board_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_lists_board_id_assoc_filter(query, project_lists_board_id)
      when is_nil(project_lists_board_id) do
    query
  end

  def maybe_project_lists_board_id_assoc_filter(query, project_lists_board_id) do
    query
    |> Ecto.Query.join(
      :inner,
      [project_todo_list],
      project_lists_board in ApiGateway.Models.ProjectListsBoard,
      on: project_todo_list.project_lists_board_id == ^project_lists_board_id
    )
    |> Ecto.Query.select([project_todo_list, project_lists_board], project_todo_list)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> CommonFilterHelpers.maybe_project_id_assoc_filter(filters[:project_id])
    |> maybe_project_lists_board_id_assoc_filter(filters[:project_lists_board_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_project_todo_list(id), do: Repo.get(ProjectTodoList, id)

  def get_project_todo_lists(filters \\ %{}) do
    IO.inspect(filters)

    ProjectTodoList |> add_query_filters(filters) |> Repo.all()
  end

  def create_project_todo_list(data) when is_map(data) do
    insert_rank =
      OrderedListHelpers.DB.get_new_item_insert_rank(
        ProjectTodoList,
        data[:project_lists_board_id],
        "list_order_rank"
      )

    %ProjectTodoList{}
    |> changeset(Map.put(data, :list_order_rank, insert_rank))
    |> Repo.insert()
  end

  def update_project_todo_list(%{id: id, data: data}) do
    case get_project_todo_list(id) do
      nil ->
        {:error, "Not found"}

      project_todo_list ->
        project_todo_list
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_project_todo_list(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_project_todo_list(id) do
    case Repo.get(ProjectTodoList, id) do
      nil ->
        {:error, "Not found"}

      project_todo_list ->
        Repo.delete(project_todo_list)
    end
  end

  ####################
  # Private helpers #
  ####################
  defp _update_with_position(%__MODULE__{} = item, prev, next, data) do
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
                "project_todo_lists",
                "list_order_rank",
                "project_lists_board_id",
                item.project_lists_board_id
              )

            normalized_list_id = item.project_lists_board_id

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
