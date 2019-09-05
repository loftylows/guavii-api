defmodule ApiGateway.Models.Account.Registration do
  alias ApiGateway.Models.AccountInvitation
  alias ApiGateway.Models.WorkspaceInvitation
  alias ApiGateway.Models.Workspace
  alias ApiGateway.Models.Account.User

  def register_user_from_workspace_invitation(
        token,
        base_64_url_encoded_email,
        user_info,
        subdomain
      ) do
    base_64_url_encoded_email
    |> Base.url_decode64(padding: false)
    |> case do
      :error ->
        {:error, "User input error"}

      {:ok, email} ->
        email
        |> WorkspaceInvitation.verify_invitation_token_with_db(token)
        |> case do
          {:error, "Invitation expired"} ->
            {:error, "Account invitation expired"}

          {:error, "Already accepted"} ->
            {:error, "Account invitation already accepted"}

          {:error, "Not found"} ->
            {:error, "Invalid invitation"}

          {:ok, invite} ->
            Workspace.get_workspace_by_subdomain(subdomain)
            |> case do
              nil ->
                {:error, "User input error"}

              workspace ->
                workspace_role =
                  Map.get(invite, :workspace_role, Workspace.get_default_workspace_role())

                user_info
                |> Map.put(:email, email)
                |> Map.put(:workspace_role, workspace_role)
                |> Map.put(:workspace_id, workspace.id)
                |> User.create_user()
                |> case do
                  {:error, %{errors: _}} = error ->
                    error

                  {:error, _} ->
                    {:error, "User input error"}

                  {:ok, user} ->
                    %{email: email, data: %{accepted: true}}
                    |> WorkspaceInvitation.update_workspace_invitation()
                    |> case do
                      {:error, _} ->
                        User.delete_user(user.id)
                        {:error, "Internal error"}

                      {:ok, _} ->
                        {:ok, %{user: user, workspace: workspace}}
                    end
                end
            end
        end
    end
  end

  def register_user_and_workspace(token, base_64_url_encoded_email, user_info, workspace_info) do
    base_64_url_encoded_email
    |> Base.url_decode64(padding: false)
    |> case do
      :error ->
        {:error, "User input error"}

      {:ok, email} ->
        email
        |> AccountInvitation.verify_invitation_token_with_db(token)
        |> case do
          {:error, "Invitation expired"} ->
            {:error, "Account invitation expired"}

          {:error, "Already accepted"} ->
            {:error, "Account invitation already accepted"}

          {:error, "Not found"} ->
            {:error, "Invalid invitation"}

          {:ok, _} ->
            workspace_info
            |> Map.put(:workspace_subdomain, workspace_info[:subdomain])
            |> Workspace.create_workspace()
            |> case do
              {:error, %{errors: _}} = error ->
                error

              {:error, "Subdomain taken"} = error ->
                error

              {:error, _} ->
                {:error, "User input error"}

              {:ok, workspace} ->
                workspace_roles = Workspace.get_workspace_roles_map()

                user_info
                |> Map.put(:email, email)
                |> Map.put(:workspace_role, workspace_roles.owner)
                |> Map.put(:workspace_id, workspace.id)
                |> User.create_user()
                |> case do
                  {:error, %{errors: _}} = error ->
                    Workspace.delete_workspace(workspace.id)
                    error

                  {:error, _} ->
                    Workspace.delete_workspace(workspace.id)
                    {:error, "User input error"}

                  {:ok, user} ->
                    %{email: email, data: %{accepted: true}}
                    |> AccountInvitation.update_account_invitation()
                    |> case do
                      {:error, _} ->
                        # user will be deleted as well by DB on_delete cascade
                        Workspace.delete_workspace(workspace.id)
                        {:error, "Internal error"}

                      {:ok, _} ->
                        {:ok, %{user: user, workspace: workspace}}
                    end
                end
            end
        end
    end
  end
end
