defmodule ApiGatewayWeb.Plug.GqlContext do
  @behaviour Plug

  import Plug.Conn
  alias ApiGateway.Models

  def init(opts), do: opts

  def call(conn, _) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  @doc """
  Return the current user context based on the session
  """
  def build_context(conn) do
    %{
      current_user: conn.assigns[:current_user],
      current_subdomain: conn.assigns[:current_subdomain]
    }
  end
end
