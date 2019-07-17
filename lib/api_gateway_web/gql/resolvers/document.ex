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
end
