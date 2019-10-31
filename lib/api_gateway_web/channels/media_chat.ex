defmodule ApiGatewayWeb.Channels.MediaChat do
  use ApiGatewayWeb, :channel

  require Logger

  alias ApiGatewayWeb.Presence
  alias ApiGateway.Models.MediaChat

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
        MediaChat.persist_chat(chat_id)

        {:ok, _} =
          Presence.track(socket, user_id, %{
            online_at: inspect(System.system_time(:second))
          })

        do_broadcast(chat_id, "join", %{type: "join", chat_id: chat_id, userId: user_id})

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
        @channel_topic_prefix <> "join",
        %{"type" => "join", "chatId" => chat_id, "userId" => user_id},
        socket
      ) do
    do_broadcast(chat_id, "join", %{type: "join", userId: user_id})

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> "offer",
        %{
          "type" => "offer",
          "offer" => offer,
          "chatId" => chat_id,
          "toId" => to_id,
          "userId" => user_id
        } = msg,
        socket
      ) do
    Logger.debug("Sending offer to chat_id: #{chat_id}")

    String.split(offer["sdp"], "\r\n")
    |> Enum.each(&Logger.debug(&1))

    # Logger.debug "offer #{user_id} #{inspect offer}"

    do_broadcast(chat_id, "offer", %{
      type: "offer",
      offer: msg["offer"],
      toId: to_id,
      userId: user_id
    })

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> "answer",
        %{
          "type" => "answer",
          "answer" => answer,
          "chatId" => chat_id,
          "toId" => to_id,
          "userId" => user_id
        } = msg,
        socket
      ) do
    Logger.debug("answer #{user_id} #{inspect(answer)}")

    # String.split(answer["sdp"], "\r\n")
    # |> Enum.each(&Logger.debug(&1))

    do_broadcast(chat_id, "answer", %{
      type: "answer",
      answer: msg["answer"],
      toId: to_id,
      userId: user_id
    })

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> "candidate",
        %{
          "type" => "candidate",
          "candidate" => candidate,
          "chatId" => chat_id,
          "userId" => user_id
        } = msg,
        socket
      ) do
    Logger.debug("Sending candidate to chat_id: #{chat_id}: #{inspect(candidate)}")

    do_broadcast(chat_id, "candidate", %{candidate: msg["candidate"], userId: user_id})

    {:noreply, socket}
  end

  def handle_in(
        @channel_topic_prefix <> "leave",
        %{"type" => "leave", "chatId" => chat_id, "userId" => user_id},
        socket
      ) do
    Logger.debug("Disconnecting from chat_id:  #{chat_id}")

    do_broadcast(chat_id, "leave", %{type: "leave", userId: user_id})

    {:noreply, socket}
  end

  def handle_in(topic, data, socket) do
    Logger.debug("Unknown -- topic: #{topic}, data: #{inspect(data)}")

    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Presence.untrack(socket, socket.assigns.user.id)

    Map.get(socket.assigns, :media_chat_id)
    |> case do
      nil ->
        nil

      media_chat_id ->
        do_broadcast(media_chat_id, "leave", %{type: "leave", userId: socket.assigns.user.id})

        Presence.list(@channel_topic_prefix <> media_chat_id)
        |> case do
          # if the presence list is now empty then spawn a new process and check again in 10 seconds
          presence_map when presence_map == %{} ->
            # wait for 10 seconds to see if any users connect/re-connect before ending the chat.
            # do this in another process so this process doesn't block
            spawn(fn ->
              Process.sleep(5_000)

              Presence.list(@channel_topic_prefix <> media_chat_id)
              |> case do
                # if the presence list is now empty then delete the chat key from redis
                presence_map when presence_map == %{} ->
                  MediaChat.delete_chat(media_chat_id)

                  Absinthe.Subscription.publish(
                    ApiGatewayWeb.Endpoint,
                    media_chat_id,
                    media_chat_call_cancelled: media_chat_id
                  )

                _ ->
                  nil
              end
            end)

          _ ->
            nil
        end
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
