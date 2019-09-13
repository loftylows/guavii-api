# TODO: refactor this module
defmodule ApiGateway.Email.Transactional do
  import Bamboo.Email
  import Bamboo.PostmarkHelper

  alias ApiGatewayWeb.Router.{WebsiteUrl, RouteHelpers}
  alias ApiGatewayWeb.Router.WebsiteUrl

  # should be in DB
  @productName "Guavii"
  # should be in DB
  @productUrl Application.get_env(:api_gateway, :website_url)
  @productUrlWithoutProtocol Application.get_env(:api_gateway, :website_host)
  # should be in DB
  @companyName "Guavii"
  # should be in DB
  @noReplyEmailAddress "no-reply@guavii.com"
  # should be in DB
  @supportEmailAddress "support@guavii.com"

  @spec send_new_account_invitation_email(String.t(), String.t()) :: Bamboo.Email.t()
  def send_new_account_invitation_email(recipient, invite_token) do
    base_64_encoded_email = Base.url_encode64(recipient, padding: false)

    recipient
    |> build_account_invitation_email(
      base_64_encoded_email,
      invite_token
    )
    |> ApiGateway.Mailer.deliver_later()
  end

  @type workspace_invitation_input :: %{
          required(:recipient) => String.t(),
          required(:invite_token) => String.t(),
          required(:workspace_name) => String.t(),
          required(:workspace_subdomain) => String.t(),
          required(:inviter_full_name) => String.t(),
          required(:invitee_name) => String.t()
        }

  @spec send_workspace_invitation_email(workspace_invitation_input) :: Bamboo.Email.t()
  def send_workspace_invitation_email(%{
        invite_token: invite_token,
        recipient: recipient,
        workspace_name: workspace_name,
        workspace_subdomain: workspace_subdomain,
        inviter_full_name: inviter_full_name,
        invitee_name: invitee_name
      }) do
    base_64_encoded_email = Base.url_encode64(recipient, padding: false)

    build_workspace_invitation_email(%{
      base_64_encoded_email: base_64_encoded_email,
      invite_token: invite_token,
      to: recipient,
      workspace_name: workspace_name,
      workspace_subdomain: workspace_subdomain,
      inviter_full_name: inviter_full_name,
      invitee_name: invitee_name
    })
    |> ApiGateway.Mailer.deliver_later()
  end

  @spec send_forgot_password_email(String.t(), String.t(), String.t(), String.t()) ::
          Bamboo.Email.t()
  def send_forgot_password_email(recipient, user_id, subdomain, token) do
    recipient
    |> build_forgot_password_email(
      user_id,
      subdomain,
      token
    )
    |> ApiGateway.Mailer.deliver_later()
  end

  @spec send_workspaces_reminder_email(String.t(), String.t()) :: Bamboo.Email.t()
  def send_workspaces_reminder_email(recipient, token) do
    base_64_encoded_email = Base.url_encode64(recipient, padding: false)

    recipient
    |> build_workspaces_reminder_email(
      base_64_encoded_email,
      token
    )
    |> ApiGateway.Mailer.deliver_later()
  end

  ####################
  # Builder funcs #
  ####################
  defp build_account_invitation_email(to, base_64_encoded_email, invite_token) do
    website_routes = RouteHelpers.get_website_routes()

    query_params = %{
      invite: invite_token,
      email: base_64_encoded_email
    }

    action_url =
      RouteHelpers.build_website_url_to_string(%WebsiteUrl{
        query_params: query_params,
        path: website_routes.get_started_account_invite
      })

    template_params = %{
      product_name: @productName,
      product_url: @productUrl,
      action_url: action_url,
      support_email: @supportEmailAddress,
      product_url_without_protocol: @productUrlWithoutProtocol,
      current_year: "#{DateTime.utc_now().year}",
      company_name: @companyName
    }

    new_email()
    |> to(to)
    |> from(@noReplyEmailAddress)
    |> template("11628349", template_params)
  end

  defp build_workspace_invitation_email(%{
         to: to,
         base_64_encoded_email: base_64_encoded_email,
         invite_token: invite_token,
         workspace_name: workspace_name,
         workspace_subdomain: workspace_subdomain,
         inviter_full_name: inviter_full_name,
         invitee_name: invitee_name
       }) do
    website_routes = RouteHelpers.get_website_routes()

    query_params = %{
      invite: invite_token,
      email: base_64_encoded_email
    }

    action_url =
      RouteHelpers.build_website_url_to_string(%WebsiteUrl{
        query_params: query_params,
        path: website_routes.get_started_workspace_invite,
        subdomain: workspace_subdomain
      })

    template_params = %{
      workspace_name: Utils.String.title_capitalize(workspace_name),
      inviter_full_name: inviter_full_name,
      name: Utils.String.title_capitalize(invitee_name),
      product_name: @productName,
      product_url: @productUrl,
      action_url: action_url,
      support_email: @supportEmailAddress,
      product_url_without_protocol: @productUrlWithoutProtocol,
      current_year: "#{DateTime.utc_now().year}",
      company_name: @companyName
    }

    new_email()
    |> to(to)
    |> from(@noReplyEmailAddress)
    |> template("11628353", template_params)
  end

  defp build_forgot_password_email(to, user_id, subdomain, token) do
    website_routes = RouteHelpers.get_website_routes()

    query_params = %{
      token: token,
      user_id: user_id
    }

    action_url =
      RouteHelpers.build_website_url_to_string(%WebsiteUrl{
        subdomain: subdomain,
        query_params: query_params,
        path: website_routes.reset_password_path
      })

    template_params = %{
      product_name: @productName,
      product_url: @productUrl,
      action_url: action_url,
      support_email: @supportEmailAddress,
      product_url_without_protocol: @productUrlWithoutProtocol,
      current_year: "#{DateTime.utc_now().year}",
      company_name: @companyName,
      workspace_url_without_protocol: "#{subdomain}.#{website_routes.website_host}"
    }

    new_email()
    |> to(to)
    |> from(@noReplyEmailAddress)
    |> template("11870080", template_params)
  end

  defp build_workspaces_reminder_email(to, base_64_encoded_email, token) do
    website_routes = RouteHelpers.get_website_routes()

    query_params = %{
      invite: token,
      email: base_64_encoded_email
    }

    action_url =
      RouteHelpers.build_website_url_to_string(%WebsiteUrl{
        query_params: query_params,
        path: website_routes.found_my_workspaces_path
      })

    template_params = %{
      product_name: @productName,
      product_url: @productUrl,
      action_url: action_url,
      support_email: @supportEmailAddress,
      current_year: "#{DateTime.utc_now().year}",
      company_name: @companyName
    }

    new_email()
    |> to(to)
    |> from(@noReplyEmailAddress)
    |> template("11870374", template_params)
  end
end
