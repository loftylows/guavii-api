defmodule ApiGatewayWeb.Channels.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: ApiGatewayWeb.Gql.Schema.Schema
  alias ApiGateway.Models.Account.User

  ## Channels
  channel "workspace:*", ApiGatewayWeb.Channels.Workspace
  channel "document:*", ApiGatewayWeb.Channels.ActiveDocumentUsers

  channel "#{ApiGatewayWeb.Channels.MediaChat.get_channel_topic_prefix()}*",
          ApiGatewayWeb.Channels.MediaChat

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket, _connect_info) do
    ApiGatewayWeb.Session.verify_token(token)
    |> case do
      {:error, _} ->
        :error

      {:ok, user_id} ->
        status_options = User.get_user_billing_status_options_map()
        active_status = status_options.active
        deactivated_status = status_options.deactivated

        ApiGateway.Models.Account.User.get_user(user_id)
        |> case do
          nil ->
            :error

          %User{billing_status: ^deactivated_status} ->
            :error

          %User{billing_status: ^active_status} = user ->
            {:ok, assign(socket, :user, user)}
        end
    end
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ApiGatewayWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # TODO: use this to disconnect all sockets for a given user when the user should be forced to reconnect
  def id(socket), do: "user_socket:#{socket.assigns.user.id}"
end
