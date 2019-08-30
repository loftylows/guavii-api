defmodule ApiGateway.Models.Document do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  alias ApiGateway.Models.DocumentLastUpdate

  schema "documents" do
    field :title, :string
    field :content, :string, read_after_writes: true
    field :is_pinned, :boolean, read_after_writes: true

    has_one :last_update, DocumentLastUpdate, on_replace: :update

    belongs_to :project, ApiGateway.Models.Project

    timestamps()
  end

  @permitted_fields [
    :title,
    :content,
    :is_pinned,
    :project_id
  ]
  @required_fields [
    :title,
    :project_id
  ]

  def changeset(%ApiGateway.Models.Document{} = document, attrs \\ %{}) do
    document
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:project_id)
  end

  ####################
  # Query helpers #
  ####################
  @doc "project_id must be a valid 'uuid' or an error will be raised"
  def maybe_project_id_assoc_filter(query, nil) do
    query
  end

  def maybe_project_id_assoc_filter(query, project_id) do
    query
    |> Ecto.Query.where([x], x.project_id == ^project_id)
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
    |> CommonFilterHelpers.maybe_distinct(filters[:distinct])
    |> maybe_project_id_assoc_filter(filters[:project_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "id must be a valid 'uuid' or an error will be raised"
  def get_document(id) do
    ApiGateway.Models.Document
    |> Ecto.Query.preload(:last_update)
    |> Repo.get(id)
  end

  def get_documents(filters \\ %{}) do
    ApiGateway.Models.Document
    |> add_query_filters(filters)
    |> Ecto.Query.preload(:last_update)
    |> Repo.all()
  end

  def create_document(data, user_id) when is_map(data) and is_binary(user_id) do
    %ApiGateway.Models.Document{}
    |> changeset(data)
    |> Repo.insert()
    |> case do
      {:error, _} = error ->
        error

      {:ok, document} ->
        %{date: DateTime.utc_now(), user_id: user_id, document_id: document.id}
        |> DocumentLastUpdate.create_last_update()
        |> case do
          {:error, _} = error ->
            {:ok, _} = delete_document(document.id)
            error

          {:ok, last_update} ->
            {:ok, Map.put(document, :last_update, last_update)}
        end
    end
  end

  def update_document(%{id: id, data: data}, user_id) when is_binary(user_id) do
    case get_document(id) do
      nil ->
        {:error, "Not found"}

      document ->
        date_now = DateTime.truncate(DateTime.utc_now(), :second)

        last_update = %{user_id: user_id, date: date_now}

        document
        |> changeset(data)
        |> put_assoc(:last_update, last_update)
        |> Repo.update()
        |> case do
          {:error, _} = error ->
            error

          {:ok, document} ->
            document =
              document
              |> Repo.preload(:last_update)

            {:ok, document}
        end
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_document(id) do
    ApiGateway.Models.Document
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, "Not found"}

      document ->
        Repo.delete(document)
    end
  end
end
