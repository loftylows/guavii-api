defmodule ApiGatewayWeb.Gql.Resolvers.WorkspaceInvitation do
  alias ApiGateway.Models.WorkspaceInvitation

  def update_workspace_invitation(_, %{where: %{id: id}, data: data}, _) do
    case WorkspaceInvitation.update_workspace_invitation(%{id: id, data: data}) do
      {:ok, workspace_invitation} ->
        {:ok, workspace_invitation}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User not found")
    end
  end

  def delete_workspace_invitation(_, %{where: %{id: id}}, _) do
    case WorkspaceInvitation.delete_workspace_invitation(id) do
      {:ok, workspace_invitation} ->
        {:ok, workspace_invitation}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("User not found")
    end
  end

  def send_workspace_invitations(_, _, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def send_workspace_invitations(
        _,
        %{data: %{invitation_info_items: invitation_info_items}},
        %{context: %{current_user: current_user}}
      ) do
    spawn(fn ->
      ApiGateway.Models.Workspace.get_workspace(current_user.workspace_id)
      |> case do
        nil ->
          ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()

        workspace ->
          emails =
            for %{email: email} <- invitation_info_items do
              IO.puts("email:")
              IO.inspect(email)
              email
            end

          already_registered_users =
            ApiGateway.Models.Account.User.get_users(%{
              email_in: emails,
              workspace_id: workspace.id
            })

          # Don't send invites to those who are already members
          invitation_info_filtered =
            Enum.filter(invitation_info_items, fn %{email: email} ->
              not Enum.any?(already_registered_users, fn user -> user.email == email end)
            end)

          {:ok, invitation_tokens_with_emails_and_names} =
            ApiGateway.Models.WorkspaceInvitation.create_or_update_workspace_invitations(
              invitation_info_filtered,
              current_user
            )

          for %{email: email, name: name, invitation_token: invitation_token} <-
                invitation_tokens_with_emails_and_names do
            ApiGateway.Email.Transactional.send_workspace_invitation_email(%{
              invite_token: invitation_token,
              recipient: email,
              workspace_name: workspace.title,
              workspace_subdomain: workspace.workspace_subdomain,
              inviter_full_name: current_user.full_name,
              invitee_name: name
            })
          end
      end
    end)

    {:ok, %{ok: true}}
  end
end
