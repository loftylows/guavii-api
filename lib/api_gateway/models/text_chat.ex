defmodule ApiGateway.Models.Chat do
  require Ecto.Query
  use Ecto.Schema
  use ApiGateway.Models.SchemaBase
  import Ecto.Changeset

  alias ApiGateway.Repo
  alias ApiGateway.Ecto.CommonFilterHelpers
  # alias ApiGateway.Models.Account.User
  alias __MODULE__

  schema "chats" do
    # TODO: uncomment these fields

    # has_many :messages, ApiGateway.Models.Message
    # has_many :users, ApiGateway.Models.Account.User

    belongs_to :workspace, ApiGateway.Models.Workspace

    timestamps()
  end

  @permitted_fields [
    :workspace_id
  ]
  @required_fields [
    :workspace_id
  ]

  def changeset(%Chat{} = chat, attrs \\ %{}) do
    chat
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:workspace_id)
  end

  ####################
  # Query helpers #
  ####################

  @doc "workspace_id must be a valid 'uuid' or an error will be raised"
  def maybe_workspace_id_assoc_filter(query, workspace_id) when is_nil(workspace_id) do
    query
  end

  def maybe_workspace_id_assoc_filter(query, workspace_id) do
    query
    |> Ecto.Query.where([x], x.workspace_id == ^workspace_id)
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
    |> maybe_workspace_id_assoc_filter(filters[:workspace_id])
  end

  ####################
  # CRUD funcs #
  ####################
  @doc "chat_id must be a valid 'uuid' or an error will raise"
  def get_chat(chat_id) do
    Chat
    |> Ecto.Query.preload(:kanban_board)
    |> Ecto.Query.preload(:lists_board)
    |> Repo.get(chat_id)
  end

  def get_chats(filters \\ %{}) do
    %Chat{}
    |> add_query_filters(filters)
    |> Repo.all()
  end

  def create_chat(data) do
    %Chat{}
    |> changeset(data)
    |> Repo.insert()
  end

  def update_chat(%{id: id, data: data}) do
    case get_chat(id) do
      nil ->
        {:error, "Not found"}

      chat ->
        chat
        |> changeset(data)
        |> Repo.update()
    end
  end

  @doc "id must be a valid 'uuid' or an error will raise"
  def delete_chat(id) do
    case get_chat(id) do
      nil ->
        {:error, "Not found"}

      chat ->
        Repo.delete(chat)
    end
  end
end
