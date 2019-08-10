defmodule ApiGatewayWeb.Plug.CurrentUser do
  @behaviour Plug

  import Plug.Conn
  alias ApiGateway.Models

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> fetch_session()
    |> maybe_put_current_user()
  end

  @doc """
  Return the current user context based on the session
  """
  def maybe_put_current_user(conn) do
    case get_session(conn, :user_id) do
      nil ->
        conn

      user_id ->
        conn
        |> assign(:current_user, Models.Account.User.get_user(user_id))
    end
  end
end
