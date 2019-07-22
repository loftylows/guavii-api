defmodule ApiGateway.Models.SubListItem do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "sub_list_items" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date, :utc_datetime

    has_many :comments, ApiGateway.Models.SubListItemComment

    belongs_to :sub_list, ApiGateway.Models.SubList
    belongs_to :assigned_to, ApiGateway.Models.User, foreign_key: :user_id
    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :completed,
    :attachments,
    :due_date,
    :user_id,
    :sub_list_id,
    :project_id
  ]
  @required_fields [
    :title,
    :sub_list_id,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:sub_list_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.SubListItem{} = sub_list_item, attrs \\ %{}) do
    sub_list_item
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
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
    |> Ecto.Query.join(:inner, [sub_list_item], user in ApiGateway.Models.User,
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
  def get_sub_list_item(id), do: Repo.get(ApiGateway.Models.SubListItem, id)

  def get_sub_list_items(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.SubListItem |> add_query_filters(filters) |> Repo.all()
  end

  def create_sub_list_item(data) when is_map(data) do
    %ApiGateway.Models.SubListItem{}
    |> changeset_create(data)
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

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_sub_list_item(id) do
    case Repo.get(ApiGateway.Models.SubListItem, id) do
      nil ->
        {:error, "Not found"}

      sub_list_item ->
        Repo.delete(sub_list_item)
    end
  end
end
