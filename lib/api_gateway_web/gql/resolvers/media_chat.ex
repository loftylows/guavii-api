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
    {:ok, chat_id} = Models.MediaChat.create_new_media_chat(data, current_user)

    {:ok, %{chat_id: chat_id}}
  end
end
