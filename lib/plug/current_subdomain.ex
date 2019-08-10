defmodule ApiGatewayWeb.Plug.CurrentSubdomain do
  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _) do
    case get_subdomain(conn.host) do
      subdomain when byte_size(subdomain) > 0 ->
        conn
        |> assign(:current_subdomain, subdomain)

      _ ->
        conn
    end
  end

  defp get_subdomain(host) do
    root_host = ApiGatewayWeb.Endpoint.config(:url)[:host]
    String.replace(host, ~r/.?#{root_host}/, "")
  end
end
