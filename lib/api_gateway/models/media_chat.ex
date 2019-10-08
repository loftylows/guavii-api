defmodule ApiGateway.Models.MediaChat do
  alias ApiGateway.Models.Account.User
  alias RedixPool, as: Redis

  @spec create_new_media_chat(%{invitees: [String.t()]}, User.t()) ::
          {:ok, String.t()}
  def create_new_media_chat(%{invitees: invitees}, current_user) do
    chat_id = Ecto.UUID.generate()

    (["SADD", chat_id] ++ [current_user.id | invitees])
    |> Redis.command!()

    ["EXPIRE", chat_id, "60"]
    |> Redis.command!()

    {:ok, chat_id}
  end
end
