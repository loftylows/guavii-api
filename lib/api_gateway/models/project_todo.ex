defmodule ApiGateway.Models.ProjectTodo do
  require Logger
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "project_todos" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date_range, ApiGateway.CustomEctoTypes.EctoDateRange
    field :list_order_rank, :float

    has_many :lists, ApiGateway.Models.SubList

    belongs_to :project_todo_list, ApiGateway.Models.ProjectTodoList
    belongs_to :assigned_to, ApiGateway.Models.User, foreign_key: :user_id
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :completed,
    :description,
    :attachments,
    :due_date_range,
    :list_order_rank,
    :project_todo_list_id,
    :user_id,
    :project_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :project_todo_list_id,
    :project_id
  ]

  @permitted_fields_update [
    :title,
    :completed,
    :description,
    :attachments,
    :due_date_range,
    :user_id,
    :project_id
  ]
  @required_fields_update [
    :title,
    :project_id
  ]

  def changeset(%ProjectTodo{} = project_todo, attrs \\ %{}) do
    project_todo
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:project_todo_id)
  end

  def changeset_update(%ProjectTodo{} = project_todo, attrs \\ %{}) do
    project_todo
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_number(:list_order_rank, greater_than: 0, less_than: 100_000_000)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:project_todo_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "project_todo_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_todo_list_id_assoc_filter(query, project_todo_list_id)
      when is_nil(project_todo_list_id) do
    query
  end

  def maybe_project_todo_list_id_assoc_filter(query, project_todo_list_id) do
    query
    |> Ecto.Query.join(
      :inner,
      [project_todo],
      project_todo_list in ApiGateway.Models.ProjectTodoList,
      on: project_todo.project_todo_list_id == ^project_todo_list_id
    )
    |> Ecto.Query.select([project_todo, project_todo_list], project_todo)
  end

  @doc "assigned_to_id must be a valid 'uuid' or an error will be raised"
  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) when is_nil(assigned_to_id) do
    query
  end

  def maybe_assigned_to_id_assoc_filter(query, assigned_to_id) do
    query
    |> Ecto.Query.join(:inner, [project_todo], user in ApiGateway.Models.User,
      on: project_todo.user_id == ^assigned_to_id
    )
    |> Ecto.Query.select([project_todo, user], project_todo)
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
    |> maybe_project_todo_list_id_assoc_filter(filters[:project_todo_list_id])
    |> maybe_assigned_to_id_assoc_filter(filters[:assigned_to])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_project_todo(id), do: Repo.get(ProjectTodo, id)

  def get_project_todos(filters \\ %{}) do
    IO.inspect(filters)

    ProjectTodo |> add_query_filters(filters) |> Repo.all()
  end

  def create_project_todo(data) when is_map(data) do
    %ProjectTodo{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update_project_todo(%{id: id, data: data}) do
    case get_project_todo(id) do
      nil ->
        {:error, "Not found"}

      project_todo ->
        project_todo
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_project_todo(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_project_todo(id) do
    case Repo.get(ProjectTodo, id) do
      nil ->
        {:error, "Not found"}

      project_todo ->
        Repo.delete(project_todo)
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
                "project_todos",
                "list_order_rank",
                "project_todo_list_id",
                item.project_todo_list_id
              )

            normalized_list_id = item.project_todo_list_id

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
