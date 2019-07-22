defmodule ApiGateway.Models.KanbanCard do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "kanban_cards" do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, {:array, :string}
    field :due_date_range, ApiGateway.CustomEctoTypes.EctoDateRange

    has_many :todo_lists, ApiGateway.Models.KanbanCardTodoList
    has_many :comments, ApiGateway.Models.KanbanCardComment

    many_to_many :activeLabels, ApiGateway.Models.KanbanLabel,
      join_through: "kanban_cards_active_labels"

    belongs_to :kanban_lane, ApiGateway.Models.KanbanLane
    belongs_to :project, ApiGateway.Models.Project
    belongs_to :assignedTo, ApiGateway.Models.User, foreign_key: :user_id

    timestamps()
  end

  @permitted_fields [
    :title,
    :description,
    :completed,
    :attachments,
    :due_date_range,
    :kanban_lane_id,
    :project_id,
    :user_id
  ]
  @required_fields [
    :title,
    :kanban_lane_id,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
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
    |> Ecto.Query.join(:inner, [kanban_card], user in ApiGateway.Models.User,
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
  def get_kanban_card(kanban_card_id), do: Repo.get(ApiGateway.Models.KanbanCard, kanban_card_id)

  def get_kanban_cards(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.KanbanCard |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_card(data) when is_map(data) do
    %ApiGateway.Models.KanbanCard{}
    |> changeset_create(data)
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

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_card(id) do
    case Repo.get(ApiGateway.Models.KanbanCard, id) do
      nil ->
        {:error, "Not found"}

      kanban_card ->
        Repo.delete(kanban_card)
    end
  end
end
