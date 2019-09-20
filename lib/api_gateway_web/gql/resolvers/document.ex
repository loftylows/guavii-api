defmodule ApiGatewayWeb.Gql.Resolvers.Document do
  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.Account.User

  def get_document(_, %{where: %{id: document_id}}, _) do
    {:ok, ApiGateway.Models.Document.get_document(document_id)}
  end

  def get_documents(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Document.get_documents(filters)}
  end

  def get_documents(_, _, _) do
    {:ok, ApiGateway.Models.Document.get_documents()}
  end

  def create_document(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def create_document(_, %{data: data}, %{context: %{current_user: user}}) do
    case ApiGateway.Models.Document.create_document(data, user.id) do
      {:ok, document} ->
        {:ok, document}

      {:error, %{changes: %{last_update: %{errors: errors}}}}
      when is_list(errors) and length(errors) > 0 ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Document input error",
          errors
        )

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Document input error",
          errors
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document input error")
    end
  end

  def update_document(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def update_document(_, %{data: %{content: _content}, where: %{id: _id}}, %{
        context: %{current_user: nil}
      }) do
    ApiGatewayWeb.Gql.Utils.Errors.user_input_error(
      "Content should only be updated using the 'update_document_content' mutation."
    )
  end

  def update_document(_, %{data: data, where: %{id: id}}, %{context: %{current_user: user}}) do
    # Regular update operation should not update content
    data_without_content = Map.delete(data, :content)

    case ApiGateway.Models.Document.update_document(
           %{id: id, data: data_without_content},
           user.id
         ) do
      {:ok, document} ->
        {:ok, document}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Document input error",
          errors
        )

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document input error")
    end
  end

  def update_document_content(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def update_document_content(
        _,
        %{data: %{content: content}, where: %{id: id}},
        %{context: %{current_user: user}}
      ) do
    case ApiGateway.Models.Document.update_document(%{id: id, data: %{content: content}}, user.id) do
      {:ok, document} ->
        {:ok, document}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Document input error",
          errors
        )

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document input error")
    end
  end

  def on_document_selection_change(
        _,
        _,
        %{context: %{current_user: nil}}
      ) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def on_document_selection_change(
        _,
        %{data: %{range: range}, where: %{id: id}},
        %{context: %{current_user: current_user}}
      ) do
    {:ok, %{id: id, range: range, user: current_user}}
  end

  def delete_document(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Document.delete_document(id) do
      {:ok, document} ->
        {:ok, document}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document not found")
    end
  end

  @spec active_users(ApiGateway.Models.Document.t()) :: [ApiGateway.Models.Account.User.t()]
  def active_users(%ApiGateway.Models.Document{} = document) do
    Presence.list("document:#{document.id}")
    |> case do
      [] ->
        []

      presences ->
        user_ids = Enum.map(presences, fn {user_id, _meta} -> user_id end)

        User.get_users(%{id_in: user_ids})
    end
  end
end
