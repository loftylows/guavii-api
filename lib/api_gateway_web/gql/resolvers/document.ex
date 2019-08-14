defmodule ApiGatewayWeb.Gql.Resolvers.Document do
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

  def update_document(_, %{data: data, where: %{id: id}}, %{context: %{current_user: user}}) do
    case ApiGateway.Models.Document.update_document(%{id: id, data: data}, user.id) do
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

  def delete_document(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Document.delete_document(id) do
      {:ok, document} ->
        {:ok, document}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Document not found")
    end
  end
end
