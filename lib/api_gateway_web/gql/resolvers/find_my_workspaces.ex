defmodule ApiGatewayWeb.Gql.Resolvers.FindMyWorkspaces do
  alias ApiGateway.Models.FindMyWorkspacesInvitation
  alias ApiGateway.Models.Account.User

  def send_find_my_workspaces_invitation(_, %{data: %{email: email}}, _) do
    case User.get_users(%{first: true, email_in: email}) do
      [] ->
        {:ok, %{ok: true}}

      _ ->
        {:ok, token} =
          FindMyWorkspacesInvitation.create_or_update_find_my_workspaces_invitation(%{
            email: email
          })

        ApiGateway.Email.Transactional.send_workspaces_reminder_email(
          email,
          token
        )

        {:ok, %{ok: true}}
    end
  end

  def find_my_workspaces(_, %{data: %{email: email, token: token}}, _) do
    case FindMyWorkspacesInvitation.find_my_workspaces(email, token) do
      {:error, "Invitation expired"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error(
          "Your 'find my workspaces' mail token has expired"
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()

      workspaces ->
        {:ok, workspaces}
    end
  end
end
