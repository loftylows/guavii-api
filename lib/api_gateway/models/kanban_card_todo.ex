defmodule ApiGateway.Models.KanbanCardTodo do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Ecto.OrderedListHelpers
  alias __MODULE__

  schema "kanban_card_todos" do
    field :title, :string
    field :completed, :boolean
    field :due_date, :utc_datetime
    field :list_order_rank, :float

    belongs_to :todo_list, ApiGateway.Models.KanbanCardTodoList,
      foreign_key: :kanban_card_todo_list_id

    belongs_to :assigned_to, ApiGateway.Models.User, foreign_key: :user_id
    belongs_to :card, ApiGateway.Models.KanbanCard
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :completed,
    :due_date,
    :list_order_rank,
    :kanban_card_todo_list_id,
    :user_id,
    :card_id,
    :project_id
  ]
  @required_fields [
    :title,
    :list_order_rank,
    :kanban_card_todo_list_id,
    :card_id,
    :project_id
  ]

  @permitted_fields_update [
    :title,
    :completed,
    :due_date,
    :user_id,
    :card_id,
    :project_id
  ]
  @required_fields_update [
    :title,
    :card_id,
    :project_id
  ]

  def changeset(
        %KanbanCardTodo{} = kanban_card_todo,
        attrs \\ %{}
      ) do
    kanban_card_todo
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:card_id)
    |> foreign_key_constraint(:kanban_card_todo_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(
        %KanbanCardTodo{} = kanban_card_todo,
        attrs \\ %{}
      ) do
    kanban_card_todo
    |> cast(attrs, @permitted_fields_update)
    |> validate_required(@required_fields_update)
    |> unique_constraint(:list_order_rank)
    |> foreign_key_constraint(:card_id)
    |> foreign_key_constraint(:kanban_card_todo_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_id_assoc_filter(query, project_id) when is_nil(project_id) do
    query
  end

  def maybe_project_id_assoc_filter(query, project_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_todo], project in ApiGateway.Models.Project,
      on: kanban_card_todo.project_id == ^project_id
    )
    |> Ecto.Query.select([kanban_card_todo, project], kanban_card_todo)
  end

  @doc "user_id must be a valid 'uuid' or an error will be raised"
  def maybe_user_id_assoc_filter(query, user_id) when is_nil(user_id) do
    query
  end

  def maybe_user_id_assoc_filter(query, user_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_todo], user in ApiGateway.Models.User,
      on: kanban_card_todo.user_id == ^user_id
    )
    |> Ecto.Query.select([kanban_card_todo, user], kanban_card_todo)
  end

  @doc "kanban_card_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) when is_nil(kanban_card_id) do
    query
  end

  def maybe_kanban_card_id_assoc_filter(query, kanban_card_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_card_todo], kanban_card in ApiGateway.Models.KanbanCard,
      on: kanban_card_todo.kanban_card_id == ^kanban_card_id
    )
    |> Ecto.Query.select([kanban_card_todo, kanban_card], kanban_card_todo)
  end

  @doc "kanban_card_todo_list_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_card_todo_list_id_assoc_filter(query, kanban_card_todo_list_id)
      when is_nil(kanban_card_todo_list_id) do
    query
  end

  def maybe_kanban_card_todo_list_id_assoc_filter(query, kanban_card_todo_list_id) do
    query
    |> Ecto.Query.join(
      :inner,
      [kanban_card_todo],
      kanban_card_todo_list in ApiGateway.Models.KanbanCardTodoList,
      on: kanban_card_todo.kanban_card_todo_list_id == ^kanban_card_todo_list_id
    )
    |> Ecto.Query.select([kanban_card_todo, kanban_card_todo_list], kanban_card_todo)
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
    |> maybe_project_id_assoc_filter(filters[:project_id])
    |> maybe_user_id_assoc_filter(filters[:assigned_to_id])
    |> maybe_kanban_card_id_assoc_filter(filters[:kanban_card_id])
    |> maybe_kanban_card_todo_list_id_assoc_filter(filters[:kanban_card_todo_list_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "kanban_card_todo_id must be a valid 'uuid' or an error will be raised"
  def get_kanban_card_todo(kanban_card_todo_id),
    do: Repo.get(KanbanCardTodo, kanban_card_todo_id)

  def get_kanban_card_todos(filters \\ %{}) do
    IO.inspect(filters)

    KanbanCardTodo |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card_todo(data) when is_map(data) do
    %KanbanCardTodo{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update_kanban_card_todo(%{id: id, data: data}) do
    case get_kanban_card_todo(id) do
      nil ->
        {:error, "Not found"}

      kanban_card_todo ->
        kanban_card_todo
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  def update_with_position(%{id: id, data: data, prev: prev, next: next}) do
    case get_kanban_card_todo(id) do
      nil ->
        {:error, "Not found"}

      item ->
        _update_with_position(item, prev, next, data)
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_card_todo(id) do
    case Repo.get(ApiGateway.Models.KanbanCardTodo, id) do
      nil ->
        {:error, "Not found"}

      kanban_card_todo ->
        Repo.delete(kanban_card_todo)
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

    case OrderedListHelpers.gap_acceptable?(prev, next) do
      true ->
        {:ok, item}

      false ->
        # TODO: possibly run this inside of another process so as not to slow the request down
        OrderedListHelpers.DB.normalize_list_order(
          "kanban_card_todos",
          "list_order_rank",
          "kanban_card_todo_list_id",
          item.kanban_card_todo_list_id
        )

        {ApiGateway.Repo.get(__MODULE__, item.id), :list_order_normalized}
    end
  end
end
