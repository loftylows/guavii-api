defmodule ApiGatewayWeb.Gql.Resolvers.MediaChat do
  alias ApiGateway.Models

  def create_new_media_chat(_, %{data: _}, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def create_new_media_chat(
        _,
        %{data: data},
        %{context: %{current_user: current_user}}
      ) do
    {:ok, chat_id, _redis_key} = Models.MediaChat.create_new_chat(data, current_user)

    {:ok, %{chat_id: chat_id}}
  end

  def check_user_can_enter_media_chat(
        _,
        %{data: %{chat_id: chat_id}},
        %{context: %{current_user: current_user}}
      ) do
    Models.MediaChat.user_in_chat_invitees?(current_user.id, chat_id)
    |> case do
      false ->
        {:ok, false}

      true ->
        {:ok, true}
    end
  end
end
