defmodule ApiGatewayWeb.Channels.ActiveDocumentUsers do
  use ApiGatewayWeb, :channel
  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.Document
  alias ApiGateway.Models.Account.User

  def join("document:" <> document_id, _params, socket) do
    Document.get_document(document_id)
    |> case do
      nil ->
        {:error, %{reason: "FORBIDDEN"}}

      document ->
        {:ok, _} =
          User.get_user(socket.assigns.user.id)
          |> case do
            nil ->
              {:error, %{reason: "FORBIDDEN"}}

            user ->
              Presence.track(socket, socket.assigns.user.id, %{
                online_at: inspect(System.system_time(:second))
              })

              Absinthe.Subscription.publish(
                ApiGatewayWeb.Endpoint,
                %{user: user, document: document},
                user_presence_joined_document: document_id
              )

              {:ok, assign(socket, :document_id, document_id)}
          end
    end
  end

  def terminate(_reason, socket) do
    Document.get_document(socket.assigns.document_id)
    |> case do
      nil ->
        :ok

      document ->
        User.get_user(socket.assigns.user.id)
        |> case do
          nil ->
            Presence.untrack(socket, socket.assigns.user.id)

            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              %{user: nil, document: document},
              user_presence_left_document: socket.assigns.document_id
            )

          user ->
            Presence.untrack(socket, socket.assigns.user.id)

            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              %{user: user, document: document},
              user_presence_left_document: socket.assigns.document_id
            )
        end

        :ok
    end
  end
end
