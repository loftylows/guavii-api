defmodule ApiGateway.Models.MediaChat do
  alias ApiGateway.Models.Account.User
  alias ApiGatewayWeb.Presence
  alias RedixPool, as: Redis

  # seconds
  @redis_key_expiration 60
  @redis_key_max_expiration 86400
  @redis_key_expiration_string "#{@redis_key_expiration}"
  @redis_key_max_expiration_string "#{@redis_key_max_expiration}"
  @redis_key_prefix "media_chat"
  @redis_chat_caller_key "caller_id"
  @redis_chat_recipient_key "recipient_id"
  @redis_chat_invitee_key_prefix "invitee"

  @spec create_new_chat(%{required(:recipient_id) => Ecto.UUID.t()}, User.t()) ::
          {:ok, chat_id :: Ecto.UUID.t(), redis_key :: String.t()} | :invalid_user_invited
  def create_new_chat(%{recipient_id: recipient_id}, current_user) do
    User.get_user(recipient_id)
    |> case do
      nil ->
        :invalid_user_invited

      _ ->
        {chat_id, redis_key} = create_chat_id()

        [
          "HMSET",
          redis_key,
          @redis_chat_caller_key,
          current_user.id,
          @redis_chat_recipient_key,
          recipient_id
        ]
        |> Redis.command!()

        ["EXPIRE", redis_key, @redis_key_expiration_string]
        |> Redis.command!()

        {:ok, chat_id, redis_key}
    end
  end

  @spec delete_chat(chat_id :: Ecto.UUID.t()) :: 1 | 0
  def delete_chat(chat_id) do
    ["DEL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
  end

  @spec add_user_to_chat(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: 1 | 0
  def add_user_to_chat(user_id, chat_id) do
    ["HSET", chat_id_to_redis_key(chat_id), user_id_to_redis_chat_invitee_key(user_id), user_id]
    |> Redis.command!()
  end

  @spec remove_user_from_chat(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: 1 | 0
  def remove_user_from_chat(user_id, chat_id) do
    ["HDEL", chat_id_to_redis_key(chat_id), user_id_to_redis_chat_invitee_key(user_id)]
    |> Redis.command!()
  end

  @spec get_chat_member_ids(chat_id :: Ecto.UUID.t()) :: [Ecto.UUID.t()]
  def get_chat_member_ids(chat_id) do
    IO.inspect(chat_id)

    ["HGETALL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
    |> parse_hgetall_response()
    |> Enum.filter(fn {key, _} ->
      cond do
        key == @redis_chat_caller_key ->
          true

        key == @redis_chat_recipient_key ->
          true

        String.starts_with?(key, @redis_chat_invitee_key_prefix) ->
          true

        true ->
          false
      end
    end)
    |> Enum.map(fn {_, user_id} -> user_id end)
  end

  @spec persist_chat(chat_id :: Ecto.UUID.t()) :: 1 | 0
  def persist_chat(chat_id) do
    ["EXPIRE", chat_id_to_redis_key(chat_id), @redis_key_max_expiration_string]
    |> Redis.command!()
  end

  @spec chat_exists?(chat_id :: Ecto.UUID.t()) :: boolean
  def chat_exists?(chat_id) do
    ["EXISTS", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
    |> case do
      0 ->
        false

      1 ->
        true
    end
  end

  @spec user_is_chat_member?(chat_id :: Ecto.UUID.t(), user_id :: Ecto.UUID.t()) :: boolean
  def user_is_chat_member?(chat_id, user_id) do
    redis_chat_key = chat_id_to_redis_key(chat_id)

    [caller_id, recipient_id, invitee_id] =
      [
        ["HGET", redis_chat_key, @redis_chat_caller_key],
        ["HGET", redis_chat_key, @redis_chat_recipient_key],
        ["HGET", redis_chat_key, user_id_to_redis_chat_invitee_key(user_id)]
      ]
      |> Redis.pipeline!()

    caller_id == user_id or recipient_id == user_id or invitee_id == user_id
  end

  @type get_media_chat_info_reply :: %{
          required(:user_can_enter_chat) => boolean,
          required(:users) => [User.t()]
        }
  @spec get_media_chat_info(chat_id :: Ecto.UUID.t(), current_user :: User.t()) ::
          get_media_chat_info_reply | {:error, :forbidden}
  def get_media_chat_info(chat_id, current_user) do
    user_is_chat_member?(chat_id, current_user.id)
    |> case do
      false ->
        {:error, :forbidden}

      true ->
        user_id_list = get_chat_member_ids(chat_id)

        IO.inspect(user_id_list)
        users = User.get_users(%{id_in: user_id_list})

        users
        |> Enum.find(fn user -> user.id == current_user.id end)
        |> is_nil()
        |> Kernel.not()
        |> case do
          false ->
            %{user_can_enter_chat: false, users: [], activeUserIds: []}

          true ->
            active_user_ids =
              Presence.list(
                ApiGatewayWeb.Channels.MediaChat.get_channel_topic_prefix() <> chat_id
              )
              |> Enum.into([], fn {user_id, _} -> user_id end)

            %{user_can_enter_chat: true, users: users, active_user_ids: active_user_ids}
        end
    end
  end

  # Utils

  @spec create_chat_id :: {chat_id :: Ecto.UUID.t(), redis_key :: String.t()}
  def create_chat_id() do
    chat_id = Ecto.UUID.generate()
    redis_key = chat_id_to_redis_key(chat_id)

    {chat_id, redis_key}
  end

  @spec chat_id_to_redis_key(chat_id :: Ecto.UUID.t()) :: String.t()
  def chat_id_to_redis_key(chat_id) do
    "#{@redis_key_prefix}:#{chat_id}"
  end

  @spec user_id_to_redis_chat_invitee_key(user_id :: Ecto.UUID.t()) :: String.t()
  def user_id_to_redis_chat_invitee_key(user_id) do
    "#{@redis_chat_invitee_key_prefix}:#{user_id}"
  end

  @spec parse_hgetall_response(res :: [String.t()]) :: [{key :: String.t(), val :: String.t()}]
  def parse_hgetall_response([]), do: []

  def parse_hgetall_response(res) when rem(length(res), 2) != 0 do
    raise "Provided list must be empty or have an even number of members"
  end

  def parse_hgetall_response(res) do
    parse_hgetall_response_helper(res, [])
  end

  defp parse_hgetall_response_helper([key, val | []], accumulator) do
    [{key, val} | accumulator]
  end

  defp parse_hgetall_response_helper([key, val | tail], accumulator) do
    parse_hgetall_response_helper(tail, [{key, val} | accumulator])
  end
end
