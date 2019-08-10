defmodule ApiGatewayWeb.Router.WebsiteUrl do
  @env Application.get_env(:api_gateway, :environment)
  @env_is_prod @env == :prod
  @website_host Application.get_env(:api_gateway, :website_host)
  @default_transport_protocol if @env_is_prod, do: "https", else: "http"
  @port if @default_transport_protocol == "https", do: 443, else: 80

  defstruct scheme: @default_transport_protocol,
            host: @website_host,
            subdomain: nil,
            port: @port,
            path: "/",
            query_params: %{}
end
