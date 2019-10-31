defmodule ApiGateway.Models.MediaChat do
  alias ApiGateway.Models.Account.User
  alias RedixPool, as: Redis

  # seconds
  @redis_key_expiration 60
  @redis_key_max_expiration 86400
  @redis_key_expiration_string "#{@redis_key_expiration}"
  @redis_key_max_expiration_string "#{@redis_key_max_expiration}"
  @redis_key_prefix "media_chat"
  @redis_chat_caller_key "caller_id"
  @redis_chat_invitee_key_prefix "invitee"
  @chat_invitee_limit 1

  @spec create_new_chat(%{required(:invitee_ids) => [Ecto.UUID.t()]}, current_user :: User.t()) ::
          {:ok, chat_id :: Ecto.UUID.t(), redis_key :: String.t()}
          | :invalid_user_invited
          | :invitee_limit_surpassed
  def create_new_chat(%{invitee_ids: invitee_ids}, _)
      when is_list(invitee_ids) and
             (length(invitee_ids) < 1 or length(invitee_ids) > @chat_invitee_limit) do
    :invitee_limit_surpassed
  end

  def create_new_chat(%{invitee_ids: invitee_ids}, current_user) do
    User.get_users(%{id_in: invitee_ids, select_only_id: true})
    |> case do
      users when length(users) != length(invitee_ids) ->
        :invalid_user_invited

      _ ->
        {chat_id, redis_key} = create_chat_id()

        ([
           "HMSET",
           redis_key,
           @redis_chat_caller_key,
           current_user.id
         ] ++
           Enum.reduce(invitee_ids, [], fn user_id, acc ->
             [user_id_to_redis_chat_invitee_key(user_id) | [user_id | acc]]
           end))
        |> Redis.command!()

        ["EXPIRE", redis_key, @redis_key_expiration_string]
        |> Redis.command!()

        # Spawn process and then send out subscription to each user invited to the chat
        spawn(fn ->
          Enum.each(invitee_ids, fn user_id ->
            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              %{chat_id: chat_id, invited_by: User.get_user!(user_id)},
              media_chat_call_received: user_id
            )
          end)
        end)

        {:ok, chat_id, redis_key}
    end
  end

  @spec delete_chat(chat_id :: Ecto.UUID.t()) :: 1 | 0
  def delete_chat(chat_id) do
    ["DEL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
  end

  @spec add_user_to_chat(
          user_id :: Ecto.UUID.t(),
          chat_id :: Ecto.UUID.t(),
          current_user :: User.t()
        ) ::
          1 | 0 | :invitee_limit_surpassed
  def add_user_to_chat(user_id, chat_id, current_user) do
    chat_id
    |> get_chat_member_ids()
    |> length()
    |> case do
      amount when amount + 1 > @chat_invitee_limit ->
        :invitee_limit_surpassed

      _ ->
        res =
          [
            "HSET",
            chat_id_to_redis_key(chat_id),
            user_id_to_redis_chat_invitee_key(user_id),
            user_id
          ]
          |> Redis.command!()

        Absinthe.Subscription.publish(
          ApiGatewayWeb.Endpoint,
          %{chat_id: chat_id, invited_by: current_user},
          media_chat_call_received: user_id
        )

        res
    end
  end

  @spec add_users_to_chat(
          user_ids :: [Ecto.UUID.t()],
          chat_id :: Ecto.UUID.t(),
          current_user :: User.t()
        ) ::
          :ok | :invitee_limit_surpassed
  def add_users_to_chat(user_ids, chat_id, current_user) do
    chat_id
    |> get_chat_member_ids()
    |> length()
    |> case do
      amount when amount + length(user_ids) > @chat_invitee_limit ->
        :invitee_limit_surpassed

      _ ->
        ([
           "HMSET",
           chat_id_to_redis_key(chat_id)
         ] ++
           Enum.reduce(user_ids, [], fn user_id, acc ->
             [user_id_to_redis_chat_invitee_key(user_id) | [user_id | acc]]
           end))
        |> Redis.command!()

        case length(user_ids) do
          amount when amount > 2 ->
            # Spawn process and then send out subscription to each user invited to the chat
            spawn(fn ->
              Enum.each(user_ids, fn user_id ->
                Absinthe.Subscription.publish(
                  ApiGatewayWeb.Endpoint,
                  %{chat_id: chat_id, invited_by: current_user},
                  media_chat_call_received: user_id
                )
              end)
            end)

          _ ->
            Enum.each(user_ids, fn user_id ->
              Absinthe.Subscription.publish(
                ApiGatewayWeb.Endpoint,
                %{chat_id: chat_id, invited_by: current_user},
                media_chat_call_received: user_id
              )
            end)
        end

        :ok
    end
  end

  @spec remove_user_from_chat(user_id :: Ecto.UUID.t(), chat_id :: Ecto.UUID.t()) :: 1 | 0
  def remove_user_from_chat(user_id, chat_id) do
    ["HDEL", chat_id_to_redis_key(chat_id), user_id_to_redis_chat_invitee_key(user_id)]
    |> Redis.command!()
  end

  @spec get_chat_member_ids(chat_id :: Ecto.UUID.t()) :: [Ecto.UUID.t()]
  def get_chat_member_ids(chat_id) do
    IO.inspect(chat_id)

    get_chat_member_tuple_items(chat_id)
    |> Enum.map(fn {_, user_id} -> user_id end)
  end

  @spec get_chat_invitee_ids(chat_id :: Ecto.UUID.t()) :: [Ecto.UUID.t()]
  def get_chat_invitee_ids(chat_id) do
    IO.inspect(chat_id)

    get_chat_invitee_tuple_items(chat_id)
    |> Enum.map(fn {_, user_id} -> user_id end)
  end

  @spec get_grouped_chat_member_ids(chat_id :: Ecto.UUID.t()) :: %{
          caller_id: Ecto.UUID.t(),
          invitee_ids: [Ecto.UUID.t()]
        }
  def get_grouped_chat_member_ids(chat_id) do
    get_chat_member_tuple_items(chat_id)
    |> Enum.reduce(%{invitee_ids: []}, fn {key, user_id}, accumulator ->
      cond do
        key == @redis_chat_caller_key ->
          Map.put(accumulator, :caller_id, user_id)

        String.starts_with?(key, @redis_chat_invitee_key_prefix) ->
          invitee_ids = Map.get(accumulator, :invitee_ids, [])

          Map.put(accumulator, :invitee_ids, [user_id | invitee_ids])
      end
    end)
  end

  @spec get_chat_member_tuple_items(chat_id :: Ecto.UUID.t()) :: [
          {redis_chat_info_key :: String.t(), Ecto.UUID.t()}
        ]
  def get_chat_member_tuple_items(chat_id) do
    ["HGETALL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
    |> parse_hgetall_response()
    |> Enum.filter(fn {key, _} ->
      cond do
        key == @redis_chat_caller_key ->
          true

        String.starts_with?(key, @redis_chat_invitee_key_prefix) ->
          true

        true ->
          false
      end
    end)
  end

  @spec get_chat_invitee_tuple_items(chat_id :: Ecto.UUID.t()) :: [
          {redis_chat_info_key :: String.t(), Ecto.UUID.t()}
        ]
  def get_chat_invitee_tuple_items(chat_id) do
    ["HGETALL", chat_id_to_redis_key(chat_id)]
    |> Redis.command!()
    |> parse_hgetall_response()
    |> Enum.filter(fn {key, _} ->
      cond do
        String.starts_with?(key, @redis_chat_invitee_key_prefix) ->
          true

        true ->
          false
      end
    end)
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

    [caller_id, invitee_id] =
      [
        ["HGET", redis_chat_key, @redis_chat_caller_key],
        ["HGET", redis_chat_key, user_id_to_redis_chat_invitee_key(user_id)]
      ]
      |> Redis.pipeline!()

    caller_id == user_id or invitee_id == user_id
  end

  @type get_media_chat_info_reply :: %{
          required(:caller) => User.t(),
          required(:invitees) => [User.t()],
          required(:chat_user_limit) => integer
        }
  @spec get_media_chat_info(chat_id :: Ecto.UUID.t(), current_user :: User.t()) ::
          {:ok, get_media_chat_info_reply}
          | {:error, :forbidden}
          | {:error, :caller_or_recipient_is_nil}
  def get_media_chat_info(chat_id, current_user) do
    user_is_chat_member?(chat_id, current_user.id)
    |> case do
      false ->
        {:error, :forbidden}

      true ->
        %{caller_id: caller_id, invitee_ids: invitee_ids} = get_grouped_chat_member_ids(chat_id)

        caller = User.get_user(caller_id)
        invitees = if invitee_ids === [], do: [], else: User.get_users(%{id_in: invitee_ids})

        if is_nil(caller) do
          {:error, :caller_or_recipient_is_nil}
        else
          res = %{
            caller: caller,
            invitees: invitees,
            chat_user_limit: @chat_invitee_limit + 1
          }

          {:ok, res}
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
