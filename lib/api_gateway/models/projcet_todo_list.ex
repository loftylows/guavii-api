defmodule ApiGateway.Models.ProjectTodoList do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "project_todo_lists" do
    field :title, :string

    has_many :todos, ApiGateway.Models.ProjectTodo

    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :project_id
  ]
  @required_fields [
    :title,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.ProjectTodoList{} = project_todo_list, attrs \\ %{}) do
    project_todo_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
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
    |> Ecto.Query.join(:inner, [project_todo_list], project in ApiGateway.Models.Project,
      on: project_todo_list.project_id == ^project_id
    )
    |> Ecto.Query.select([project_todo_list, project], project_todo_list)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> maybe_project_id_assoc_filter(filters[:project_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_project_todo_list(id), do: Repo.get(ApiGateway.Models.ProjectTodoList, id)

  def get_project_todo_lists(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.ProjectTodoList |> add_query_filters(filters) |> Repo.all()
  end

  def create_project_todo_list(data) when is_map(data) do
    %ApiGateway.Models.ProjectTodoList{}
    |> changeset_create(data)
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

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_project_todo_list(id) do
    case Repo.get(ApiGateway.Models.ProjectTodoList, id) do
      nil ->
        {:error, "Not found"}

      project_todo_list ->
        Repo.delete(project_todo_list)
    end
  end
end
