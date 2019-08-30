defmodule ApiGatewayWeb.Gql.Resolvers.WorkspaceInvitation do
  def send_workspace_invitation(
        _,
        %{data: %{emails: emails}},
        %{current_user: current_user}
      )
      when not is_nil(current_user) do
    spawn(fn ->
      {:ok, invitation_tokens_with_emails} =
        ApiGateway.Models.WorkspaceInvitation.create_or_update_workspace_invitations(
          %{emails: emails},
          current_user
        )

      for %{email: email, invitation_token: invitation_token} <- invitation_tokens_with_emails do
        ApiGateway.Email.Transactional.send_new_workspace_invitation_email(
          email,
          invitation_token
        )
      end
    end)

    {:ok, %{ok: true}}
  end
end
