defmodule ApiGatewayWeb.Router.RouteHelpers do
  alias ApiGatewayWeb.Router.WebsiteUrl

  @website_host Application.get_env(:api_gateway, :website_host)

  def get_website_routes() do
    is_dev =
      case Application.get_env(:api_gateway, :environment) do
        :dev -> true
        :prod -> false
      end

    default_transport_protocol = if is_dev, do: "http", else: "https"
    get_started_path = "/get-started"

    %{
      default_transport_protocol: default_transport_protocol,
      website_host: @website_host,
      site_full_base_url: "#{default_transport_protocol}://#{@website_host}",
      get_started_path: "#{get_started_path}",
      get_started_account_invite: "#{get_started_path}/account-invite",
      get_started_workspace_invite: "#{get_started_path}/workspace-invite",
      forgot_password_path: "#{get_started_path}/forgot",
      reset_password_path: "#{get_started_path}/forgot/reset",
      find_my_workspaces_path: "#{get_started_path}/find-my-workspaces",
      found_my_workspaces_path: "#{get_started_path}/find-my-workspaces/workspaces"
    }
  end

  def build_website_url_to_string(%WebsiteUrl{} = url_parts) do
    base =
      if url_parts.subdomain,
        do: "#{url_parts.subdomain}.#{url_parts.host}",
        else: "#{url_parts.host}"

    %URI{
      authority: base,
      fragment: nil,
      host: base,
      path: url_parts.path,
      port: url_parts.port,
      query: URI.encode_query(url_parts.query_params),
      scheme: url_parts.scheme,
      userinfo: nil
    }
    |> URI.to_string()
  end
end
