defmodule ApiGateway.Models.MediaChat do
  alias ApiGateway.Models.Account.User
  alias RedixPool, as: Redis

  # seconds
  @redis_key_expiration 60
  @redis_key_expiration_string "#{@redis_key_expiration}"
  @redis_key_prefix "media_chat"

  @spec create_new_chat(%{invitees: [Ecto.UUID.t()]}, User.t()) ::
          {:ok, chat_id :: Ecto.UUID.t(), redis_key :: String.t()}
  def create_new_chat(%{invitees: invitees}, current_user) do
    {chat_id, redis_key} = create_chat_id()

    (["SADD", redis_key] ++ [current_user.id | invitees])
    |> Redis.command!()

    ["EXPIRE", redis_key, @redis_key_expiration_string]
    |> Redis.command!()

    {:ok, chat_id, redis_key}
  end

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

  @spec delete_chat(chat_id :: Ecto.UUID.t()) :: 1 | 0
  def delete_chat(chat_id) do
    ["DEL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
  end

  @spec add_user_to_chat(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: 1 | 0
  def add_user_to_chat(user_id, chat_id) do
    ["SADD", chat_id_to_redis_key(chat_id), user_id]
    |> Redis.command!()
  end

  @spec remove_user_from_chat(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: 1 | 0
  def remove_user_from_chat(user_id, chat_id) do
    ["SREM", chat_id_to_redis_key(chat_id), user_id]
    |> Redis.command!()
  end

  @spec persist_chat(chat_id :: Ecto.UUID.t()) :: 1 | 0
  def persist_chat(chat_id) do
    ["PERSIST", chat_id_to_redis_key(chat_id)]
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

  @spec user_in_chat_invitees?(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: boolean
  def user_in_chat_invitees?(user_id, chat_id) do
    ["SISMEMBER", chat_id_to_redis_key(chat_id), user_id]
    |> Redis.command!()
    |> case do
      0 ->
        false

      1 ->
        true
    end
  end
end
