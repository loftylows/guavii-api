defmodule ApiGateway.Models.Document do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers

  schema "projects" do
    field :title, :string
    field :content, :string
    field :is_pinned, :boolean

    embeds_one :last_update, LastUpdate do
      field :date, :utc_datetime

      belongs_to :user, ApiGateway.Models.Account.User
    end

    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :content,
    :is_pinned,
    :last_update,
    :project_id
  ]
  @required_fields [
    :title,
    :content,
    :last_update,
    :project_id
  ]

  @last_update_permitted_fields [
    :date,
    :user_id
  ]

  def changeset_create(%ApiGateway.Models.Document{} = document, attrs \\ %{}) do
    document
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:last_update, with: &last_update_changeset/2)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  def changeset_update(%ApiGateway.Models.Document{} = document, attrs \\ %{}) do
    document
    |> cast(attrs, @permitted_fields)
    |> cast_embed(:last_update, with: &last_update_changeset/2)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  def last_update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @last_update_permitted_fields)
    |> validate_required(@last_update_permitted_fields)
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
    |> Ecto.Query.join(:inner, [document], project in ApiGateway.Models.Project,
      on: document.project_id == ^project_id
    )
    |> Ecto.Query.select([document, project], document)
  end

  def add_query_filters(query, nil) do
    query
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
  def get_document(id), do: Repo.get(ApiGateway.Models.Document, id)

  def get_documents(filters \\ %{}) do
    IO.inspect(filters)

    ApiGateway.Models.Document |> add_query_filters(filters) |> Repo.all()
  end

  def create_document(data, user_id) when is_map(data) and is_binary(user_id) do
    data = Map.put(data, :last_update, %{user_id: user_id, date: DateTime.utc_now()})

    %ApiGateway.Models.Document{}
    |> changeset_create(data)
    |> Repo.insert()
  end

  def update_document(%{id: id, data: data}, user_id) when is_binary(user_id) do
    case get_document(id) do
      nil ->
        {:error, "Not found"}

      document ->
        data = Map.put(data, :last_update, %{user_id: user_id, date: DateTime.utc_now()})

        document
        |> changeset_update(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_document(id) do
    case Repo.get(ApiGateway.Models.Document, id) do
      nil ->
        {:error, "Not found"}

      document ->
        Repo.delete(document)
    end
  end
end
