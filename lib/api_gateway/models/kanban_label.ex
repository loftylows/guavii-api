defmodule ApiGateway.Models.KanbanLabel do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "kanban_labels" do
    field :title, :string
    field :color, :string

    belongs_to :kanban_board, ApiGateway.Models.KanbanBoard

    timestamps()
  end

  @permitted_fields [
    :title,
    :color,
    :kanban_board_id
  ]
  @required_fields [
    :title,
    :color,
    :kanban_board_id
  ]

  def changeset_create(%ApiGateway.Models.KanbanLabel{} = kanban_label, attrs \\ %{}) do
    kanban_label
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_board_id)
  end

  def changeset_update(%ApiGateway.Models.KanbanLabel{} = kanban_label, attrs \\ %{}) do
    kanban_label
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:kanban_board_id)
  end

  ####################
  # Query helpers #
  ####################
  def maybe_color_filter(query, color \\ nil)

  def maybe_color_filter(query, color) when is_nil(color) do
    query
  end

  def maybe_color_filter(query, color) do
    query |> Ecto.Query.where([kanban_label], kanban_label.color == ^color)
  end

  @doc "kanban_board_id must be a valid 'uuid' or an error will be raised"
  def maybe_kanban_board_id_assoc_filter(query, kanban_board_id) when is_nil(kanban_board_id) do
    query
  end

  def maybe_kanban_board_id_assoc_filter(query, kanban_board_id) do
    query
    |> Ecto.Query.join(:inner, [kanban_label], kanban_board in ApiGateway.Models.KanbanBoard,
      on: kanban_label.kanban_board_id == ^kanban_board_id
    )
    |> Ecto.Query.select([kanban_label, kanban_board], kanban_label)
  end

  def add_query_filters(query, filters) when is_map(filters) do
    query
    |> CommonFilterHelpers.maybe_id_in_filter(filters[:id_in])
    |> CommonFilterHelpers.maybe_created_at_filter(filters[:created_at])
    |> CommonFilterHelpers.maybe_created_at_gte_filter(filters[:created_at_gte])
    |> CommonFilterHelpers.maybe_created_at_lte_filter(filters[:created_at_lte])
    |> CommonFilterHelpers.maybe_title_contains_filter(filters[:title_contains])
    |> maybe_color_filter(filters[:color])
    |> maybe_kanban_board_id_assoc_filter(filters[:kanban_board_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_kanban_label(id),
    do: Repo.get(ApiGateway.Models.KanbanLabel, id)

  def get_kanban_labels(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.KanbanLabel |> add_query_filters(filters) |> Repo.all()
  end

  def create_kanban_label(data) when is_map(data) do
    %ApiGateway.Models.KanbanLabel{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_kanban_label(%{id: id, data: data}) do
    case get_kanban_label(id) do
      nil ->
        {:error, "Not found"}

      kanban_label ->
        kanban_label
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_kanban_label(id) do
    case Repo.get(ApiGateway.Models.KanbanLabel, id) do
      nil ->
        {:error, "Not found"}

      kanban_label ->
        Repo.delete(kanban_label)
    end
  end
end
