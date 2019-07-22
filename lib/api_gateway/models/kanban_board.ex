defmodule ApiGateway.Models.KanbanBoard do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "kanban_boards" do
    has_many :lanes, ApiGateway.Models.KanbanLane
    has_many :labels, ApiGateway.Models.KanbanLabel
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :project_id
  ]
  @required_fields [
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanBoard{} = kanban_board, attrs \\ %{}) do
    kanban_board
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanBoard{} = kanban_board, attrs \\ %{}) do
    kanban_board
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  ####################
  # Query helpers #
  ####################
  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will raise"
  def get_kanban_board(kanban_board_id),
    do: Repo.get(ApiGateway.Models.KanbanBoard, kanban_board_id)

  def get_kanban_boards(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.KanbanBoard |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_board(data) when is_map(data) do
    %ApiGateway.Models.KanbanBoard{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_kanban_board(%{id: id, data: data}) do
    case get_kanban_board(id) do
      nil ->
        {:error, "Not found"}

      kanban_board ->
        kanban_board
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_board(id) do
    case get_kanban_board(id) do
      nil ->
        {:error, "Not found"}

      kanban_board ->
        Repo.delete(kanban_board)
    end
  end
end
