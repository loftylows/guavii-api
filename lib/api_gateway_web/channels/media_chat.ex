defmodule ApiGatewayWeb.Channels.MediaChat do
  use ApiGatewayWeb, :channel

  require Logger

  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.MediaChat
  alias ApiGateway.Models.Account.User

  @channel_topic_prefix "media_chat:"
  @forbidden_error_code "FORBIDDEN"

  def get_channel_topic_prefix() do
    @channel_topic_prefix
  end

  def join(@channel_topic_prefix <> chat_id, _params, socket) do
    user_id = socket.assigns.user.id

    can_join? =
      MediaChat.user_is_chat_member?(chat_id, user_id) and
        is_nil(Map.get(socket.assigns, :media_chat_id))

    can_join?
    |> case do
      false ->
        {:error, %{reason: @forbidden_error_code}}

      true ->
        {:ok, _} =
          Presence.track(socket, user_id, %{
            online_at: inspect(System.system_time(:second))
          })

        spawn(fn ->
          current_user = User.get_user(user_id)

          Absinthe.Subscription.publish(
            ApiGatewayWeb.Endpoint,
            current_user,
            user_joined_media_chat: chat_id
          )
        end)

        MediaChat.persist_chat(chat_id)

        {:ok, assign(socket, :media_chat_id, chat_id)}
    end
  end

  ##########
  # Outgoing message handlers

  def handle_out(event, msg, socket) do
    Logger.warn("handle_out topic: #{event}, msg: #{inspect(msg)}")

    {:noreply, socket}
  end

  ##########
  # Incoming message handlers

  def handle_in(
        @channel_topic_prefix <> chat_id,
        %{"type" => "offer", "offer" => offer} = msg,
        socket
      ) do
    Logger.debug("Sending offer to chat_id: #{chat_id}")

    String.split(offer["sdp"], "\r\n")
    |> Enum.each(&Logger.debug(&1))

    # Logger.debug "offer #{user_id} #{inspect offer}"

    do_broadcast(chat_id, "offer", %{type: "offer", offer: msg["offer"], chat_id: chat_id})

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> chat_id,
        %{"type" => "answer", "answer" => answer} = msg,
        socket
      ) do
    Logger.debug("Sending answer to chat_id: #{chat_id}")

    # Logger.debug "answer #{user_id} #{inspect answer}"

    String.split(answer["sdp"], "\r\n")
    |> Enum.each(&Logger.debug(&1))

    do_broadcast(chat_id, "answer", %{type: "answer", answer: msg["answer"]})

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> chat_id,
        %{"type" => "leave"},
        socket
      ) do
    Logger.debug("Disconnecting from chat_id:  #{chat_id}")

    do_broadcast(chat_id, "leave", %{type: "leave"})

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> chat_id,
        %{"type" => "candidate", "candidate" => candidate} = msg,
        socket
      ) do
    Logger.debug("Sending candidate to chat_id: #{chat_id}: #{inspect(candidate)}")

    do_broadcast(chat_id, "candidate", %{candidate: msg["candidate"]})

    {:noreply, socket}
  end

  def handle_in(@channel_topic_prefix <> chat_id, msg, socket) do
    type = msg["type"]

    Logger.debug("chat_id: #{chat_id}, unknown type: #{type}, msg: #{inspect(msg)}")

    do_broadcast(chat_id, "error", %{type: "error", message: "Unrecognized command: " <> type})

    {:noreply, socket}
  end

  def handle_in(topic, data, socket) do
    Logger.error("Unknown -- topic: #{topic}, data: #{inspect(data)}")

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Presence.untrack(socket, socket.assigns.user.id)

    Presence.list(@channel_topic_prefix <> socket.assigns.media_chat_id)
    |> case do
      # if the presence list is now empty then delete the chat key from redis
      presence_map when presence_map == %{} ->
        MediaChat.delete_chat(socket.assigns.media_chat_id)

      _ ->
        nil
    end

    :ok
  end

  @spec do_broadcast(any, any, any) :: :ok | {:error, term()}
  defp do_broadcast(chat_id, message, data) do
    ApiGatewayWeb.Endpoint.broadcast(
      @channel_topic_prefix <> chat_id,
      @channel_topic_prefix <> message,
      data
    )
  end
end
