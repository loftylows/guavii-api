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
  @required_fields_create [
    :title,
    :kanban_lane_id,
    :project_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanCard{} = kanban_card, attrs \\ %{}) do
    kanban_card
    |> cast(attrs, @permitted_fields)
    |> foreign_key_constraint(:kanban_lane_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:user_id)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_title_contains_filter(query, field \\ "")

  def maybe_title_contains_filter(query, field) when is_binary(field) do
    query |> Ecto.Query.where([p], like(p.title, ^"%#{String.replace(field, "%", "\\%")}%"))
  end

  def maybe_title_contains_filter(query, _) do
    query
  end

  @doc "project_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_id_assoc_filter(query, project_id) when is_nil(project_id) do
    query
  end

  def maybe_project_id_assoc_filter(query, project_id) do
    query
    |> Ecto.Query.join(:inner, [k], p in ApiGateway.Models.Project,
      on: k.project_id == ^project_id
    )
    |> Ecto.Query.select([p, k], k)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> maybe_title_contains_filter(filters[:title_contains])
    |> maybe_project_id_assoc_filter(filters[:project_id])
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
end
