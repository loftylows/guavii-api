defmodule ApiGatewayWeb.Channels.ActiveDocumentUsers do
  use ApiGatewayWeb, :channel
  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.Document

  def join("document:" <> document_id, _params, socket) do
    Document.get_document(document_id)
    |> case do
      nil ->
        {:error, %{reason: "FORBIDDEN"}}

      _document ->
        send(self(), :after_join)
        {:ok, assign(socket, :document_id, document_id)}
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    {:noreply, socket}
  end
end
