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
        Models.Account.User.get_user(user_id)
        |> case do
          nil ->
            conn

          user ->
            billing_status_map = Models.Account.User.get_user_billing_status_options_map()
            is_active_user? = user.billing_status === billing_status_map.active

            conn
            |> assign(:current_user, if(is_active_user?, do: user, else: nil))
        end
    end
  end
end
