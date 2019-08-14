defmodule ApiGateway.Models.ProjectListsBoard do
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "project_lists_boards" do
    has_many :lists, ApiGateway.Models.ProjectTodoList
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :project_id
  ]
  @required_fields [
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.ProjectListsBoard{} = project_lists_board, attrs \\ %{}) do
    project_lists_board
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.ProjectListsBoard{} = project_lists_board, attrs \\ %{}) do
    project_lists_board
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  ####################
  # Query helpers #
  ####################
  def add_query_filters(query, nil) do
    query
  end

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
  def get_project_lists_board(project_lists_board_id),
    do: Repo.get(ApiGateway.Models.ProjectListsBoard, project_lists_board_id)

  def get_project_lists_boards(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.ProjectListsBoard |> add_query_filters(filters) |> Repo.all()
  end

  def create_project_lists_board(data) when is_map(data) do
    %ApiGateway.Models.ProjectListsBoard{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_project_lists_board(%{id: id, data: data}) do
    case get_project_lists_board(id) do
      nil ->
        {:error, "Not found"}

      project_lists_board ->
        project_lists_board
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_project_lists_board(id) do
    case get_project_lists_board(id) do
      nil ->
        {:error, "Not found"}

      project_lists_board ->
        Repo.delete(project_lists_board)
    end
  end
end
