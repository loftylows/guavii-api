defmodule ApiGateway.Models.SubList do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "sub_lists" do
    field :title, :string

    has_many :lists_items, ApiGateway.Models.SubListItem

    belongs_to :project_todo, ApiGateway.Models.ProjectTodo

    timestamps()
  end

  @permitted_fields [
    :title,
    :project_todo_id
  ]
  @required_fields [
    :title,
    :project_todo_id
  ]

  def changeset_create(%ApiGateway.Models.SubList{} = sub_list, attrs \\ %{}) do
    sub_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_todo_id)
  end

  def changeset_update(%ApiGateway.Models.SubList{} = sub_list, attrs \\ %{}) do
    sub_list
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_todo_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "project_todo_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_todo_id_assoc_filter(query, project_todo_id)
      when is_nil(project_todo_id) do
    query
  end

  def maybe_project_todo_id_assoc_filter(query, project_todo_id) do
    query
    |> Ecto.Query.join(:inner, [sub_list], project_todo in ApiGateway.Models.ProjectTodo,
      on: sub_list.project_todo_id == ^project_todo_id
    )
    |> Ecto.Query.select([sub_list, project_todo], sub_list)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> maybe_project_todo_id_assoc_filter(filters[:project_todo_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_sub_list(id), do: Repo.get(ApiGateway.Models.SubList, id)

  def get_sub_lists(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.SubList |> add_query_filters(filters) |> Repo.all()
  end

  def create_sub_list(data) when is_map(data) do
    %ApiGateway.Models.SubList{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_sub_list(%{id: id, data: data}) do
    case get_sub_list(id) do
      nil ->
        {:error, "Not found"}

      sub_list ->
        sub_list
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_sub_list(id) do
    case Repo.get(ApiGateway.Models.SubList, id) do
      nil ->
        {:error, "Not found"}

      sub_list ->
        Repo.delete(sub_list)
    end
  end
end
