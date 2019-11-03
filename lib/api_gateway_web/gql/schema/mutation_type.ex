defmodule ApiGatewayWeb.Gql.Schema.MutationType do
  use Absinthe.Schema.Notation
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  alias ApiGatewayWeb.Gql.Resolvers

  object :root_mutations do
    ####################
    # Main Node mutations #
    ####################
    @desc "Update a workspace using provided data"
    field :update_workspace_invitation, non_null(:workspace_invitation) do
      arg(:where, non_null(:workspace_invitation_where_unique_input))
      arg(:data, non_null(:workspace_invitation_update_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.WorkspaceInvitation.update_workspace_invitation/3)
    end

    @desc "Delete a workspace invitation using provided data"
    field :delete_workspace_invitation, non_null(:workspace_invitation) do
      arg(:where, non_null(:workspace_invitation_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.WorkspaceInvitation.delete_workspace_invitation/3)
    end

    @desc "Create a workspace using provided data"
    field :create_workspace, non_null(:workspace) do
      arg(:data, non_null(:workspace_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Workspace.create_workspace/3)
    end

    @desc "Update a workspace using provided data"
    field :update_workspace, non_null(:workspace) do
      arg(:data, non_null(:workspace_update_input))
      arg(:where, non_null(:workspace_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Workspace.update_workspace/3)
    end

    @desc "Update a workspace using provided data"
    field :transfer_workspace_ownership, non_null_list(:user) do
      arg(:data, non_null(:transfer_workspace_ownership_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.transfer_workspace_ownership_role/3)
    end

    @desc "Delete a workspace"
    field :delete_workspace, non_null(:workspace) do
      arg(:where, non_null(:workspace_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Workspace.delete_workspace/3)
    end

    @desc "Update a user using provided data"
    field :update_user, non_null(:user) do
      arg(:data, non_null(:user_update_input))
      arg(:where, non_null(:user_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.update_user/3)
    end

    @desc "Update a user using provided data"
    field :update_user_password, non_null(:user) do
      arg(:data, non_null(:user_update_password_input))
      arg(:where, non_null(:user_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.update_user_password/3)
    end

    @desc "Create a team using provided data"
    field :create_team, non_null(:team) do
      arg(:data, non_null(:team_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Team.create_team/3)
    end

    @desc "Update a team using provided data"
    field :update_team, non_null(:team) do
      arg(:data, non_null(:team_update_input))
      arg(:where, non_null(:team_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Team.update_team/3)
    end

    @desc "Delete a team"
    field :delete_team, non_null(:team) do
      arg(:where, non_null(:team_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Team.delete_team/3)
    end

    @desc "Update a team using provided data"
    field :update_team_member, non_null(:team_member) do
      arg(:data, non_null(:team_member_update_input))
      arg(:where, non_null(:team_member_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.TeamMember.update_team_member/3)
    end

    @desc "Create a project using provided data"
    field :create_project, non_null(:project) do
      arg(:data, non_null(:project_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Project.create_project/3)
    end

    @desc "Update a project using provided data"
    field :update_project, non_null(:project) do
      arg(:data, non_null(:project_update_input))
      arg(:where, non_null(:project_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Project.update_project/3)
    end

    @desc "Delete a project"
    field :delete_project, non_null(:project) do
      arg(:where, non_null(:project_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Project.delete_project/3)
    end

    @desc "Create a document using provided data"
    field :create_document, non_null(:document) do
      arg(:data, non_null(:document_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.create_document/3)
    end

    @desc "Update a document using provided data"
    field :update_document, non_null(:document) do
      arg(:data, non_null(:document_update_input))
      arg(:where, non_null(:document_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.update_document/3)
    end

    @desc "Update a document content using provided data"
    field :update_document_content, non_null(:update_document_content_payload) do
      arg(:data, non_null(:document_update_content_input))
      arg(:where, non_null(:document_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.update_document_content/3)
    end

    @desc "Update a document content using provided data"
    field :on_document_selection_change, non_null(:on_document_selection_change_payload) do
      arg(:data, non_null(:on_document_selection_change_input))
      arg(:where, non_null(:document_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.on_document_selection_change/3)
    end

    @desc "Delete a document"
    field :delete_document, non_null(:document) do
      arg(:where, non_null(:document_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.delete_document/3)
    end

    @desc "Create a project_todo_list using provided data"
    field :create_project_todo_list, non_null(:project_todo_list) do
      arg(:data, non_null(:project_todo_list_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodoList.create_project_todo_list/3)
    end

    @desc "Update a project_todo_list using provided data"
    field :update_project_todo_list, non_null(:update_project_todo_list_payload) do
      arg(:data, non_null(:project_todo_list_update_input))
      arg(:where, non_null(:project_todo_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodoList.update_project_todo_list/3)
    end

    @desc "Delete a project_todo_list"
    field :delete_project_todo_list, non_null(:project_todo_list) do
      arg(:where, non_null(:project_todo_list_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodoList.delete_project_todo_list/3)
    end

    @desc "Create a project_todo using provided data"
    field :create_project_todo, non_null(:project_todo) do
      arg(:data, non_null(:project_todo_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodo.create_project_todo/3)
    end

    @desc "Update a project_todo using provided data"
    field :update_project_todo, non_null(:update_project_todo_payload) do
      arg(:data, non_null(:project_todo_update_input))
      arg(:where, non_null(:project_todo_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodo.update_project_todo/3)
    end

    @desc "Delete a project_todo"
    field :delete_project_todo, non_null(:project_todo) do
      arg(:where, non_null(:project_todo_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.ProjectTodo.delete_project_todo/3)
    end

    @desc "Create a sub_list using provided data"
    field :create_sub_list, non_null(:sub_list) do
      arg(:data, non_null(:sub_list_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubList.create_sub_list/3)
    end

    @desc "Update a sub_list using provided data"
    field :update_sub_list, non_null(:update_sub_list_payload) do
      arg(:data, non_null(:sub_list_update_input))
      arg(:where, non_null(:sub_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubList.update_sub_list/3)
    end

    @desc "Delete a sub_list"
    field :delete_sub_list, non_null(:sub_list) do
      arg(:where, non_null(:sub_list_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubList.delete_sub_list/3)
    end

    @desc "Create a sub_list_item using provided data"
    field :create_sub_list_item, non_null(:sub_list_item) do
      arg(:data, non_null(:sub_list_item_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItem.create_sub_list_item/3)
    end

    @desc "Update a sub_list_item using provided data"
    field :update_sub_list_item, non_null(:update_sub_list_item_payload) do
      arg(:data, non_null(:sub_list_item_update_input))
      arg(:where, non_null(:sub_list_item_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItem.update_sub_list_item/3)
    end

    @desc "Delete a sub_list_item"
    field :delete_sub_list_item, non_null(:sub_list_item) do
      arg(:where, non_null(:sub_list_item_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItem.delete_sub_list_item/3)
    end

    @desc "Create a sub_list_item_comment using provided data"
    field :create_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:data, non_null(:sub_list_item_comment_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItemComment.create_sub_list_item_comment/3)
    end

    @desc "Update a sub_list_item_comment using provided data"
    field :update_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:data, non_null(:sub_list_item_comment_update_input))
      arg(:where, non_null(:sub_list_item_comment_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItemComment.update_sub_list_item_comment/3)
    end

    @desc "Delete a sub_list_item_comment"
    field :delete_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:where, non_null(:sub_list_item_comment_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.SubListItemComment.delete_sub_list_item_comment/3)
    end

    @desc "Create a kanban_label using provided data"
    field :create_kanban_label, non_null(:kanban_label) do
      arg(:data, non_null(:kanban_label_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLabel.create_kanban_label/3)
    end

    @desc "Update a kanban_label using provided data"
    field :update_kanban_label, non_null(:kanban_label) do
      arg(:data, non_null(:kanban_label_update_input))
      arg(:where, non_null(:kanban_label_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLabel.update_kanban_label/3)
    end

    @desc "Delete a kanban_label"
    field :delete_kanban_label, non_null(:kanban_label) do
      arg(:where, non_null(:kanban_label_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLabel.delete_kanban_label/3)
    end

    @desc "Create a kanban_lane using provided data"
    field :create_kanban_lane, non_null(:kanban_lane) do
      arg(:data, non_null(:kanban_lane_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLane.create_kanban_lane/3)
    end

    @desc "Update a kanban_lane using provided data"
    field :update_kanban_lane, non_null(:update_kanban_lane_payload) do
      arg(:data, non_null(:kanban_lane_update_input))
      arg(:where, non_null(:kanban_lane_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLane.update_kanban_lane/3)
    end

    @desc "Delete a kanban_lane"
    field :delete_kanban_lane, non_null(:kanban_lane) do
      arg(:where, non_null(:kanban_lane_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanLane.delete_kanban_lane/3)
    end

    @desc "Create a kanban_card using provided data"
    field :create_kanban_card, non_null(:kanban_card) do
      arg(:data, non_null(:kanban_card_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCard.create_kanban_card/3)
    end

    @desc "Update a kanban_card using provided data"
    field :update_kanban_card, non_null(:update_kanban_card_payload) do
      arg(:data, non_null(:kanban_card_update_input))
      arg(:where, non_null(:kanban_card_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCard.update_kanban_card/3)
    end

    @desc "Delete a kanban_card"
    field :delete_kanban_card, non_null(:kanban_card) do
      arg(:where, non_null(:kanban_card_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCard.delete_kanban_card/3)
    end

    @desc "Create a kanban_card_comment using provided data"
    field :create_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:data, non_null(:kanban_card_comment_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardComment.create_kanban_card_comment/3)
    end

    @desc "Update a kanban_card_comment using provided data"
    field :update_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:data, non_null(:kanban_card_comment_update_input))
      arg(:where, non_null(:kanban_card_comment_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardComment.update_kanban_card_comment/3)
    end

    @desc "Delete a kanban_card_comment"
    field :delete_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:where, non_null(:kanban_card_comment_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardComment.delete_kanban_card_comment/3)
    end

    @desc "Create a kanban_card_todo_list using provided data"
    field :create_kanban_card_todo_list, non_null(:kanban_card_todo_list) do
      arg(:data, non_null(:kanban_card_todo_list_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodoList.create_kanban_card_todo_list/3)
    end

    @desc "Update a kanban_card_todo_list using provided data"
    field :update_kanban_card_todo_list, non_null(:update_kanban_card_todo_list_payload) do
      arg(:data, non_null(:kanban_card_todo_list_update_input))
      arg(:where, non_null(:kanban_card_todo_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodoList.update_kanban_card_todo_list/3)
    end

    @desc "Delete a kanban_card_todo_list"
    field :delete_kanban_card_todo_list, non_null(:kanban_card_todo_list) do
      arg(:where, non_null(:kanban_card_todo_list_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodoList.delete_kanban_card_todo_list/3)
    end

    @desc "Create a kanban_card_todo using provided data"
    field :create_kanban_card_todo, non_null(:kanban_card_todo) do
      arg(:data, non_null(:kanban_card_todo_create_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodo.create_kanban_card_todo/3)
    end

    @desc "Update a kanban_card_todo using provided data"
    field :update_kanban_card_todo, non_null(:update_kanban_card_todo_payload) do
      arg(:data, non_null(:kanban_card_todo_update_input))
      arg(:where, non_null(:kanban_card_todo_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodo.update_kanban_card_todo/3)
    end

    @desc "Delete a kanban_card_todo"
    field :delete_kanban_card_todo, non_null(:kanban_card_todo) do
      arg(:where, non_null(:kanban_card_todo_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodo.delete_kanban_card_todo/3)
    end

    ####################
    # Other mutations #
    ####################

    @desc "Send an account invitation using provided data"
    field :send_account_invitation, non_null(:account_invitation_send_payload) do
      arg(:data, non_null(:account_invitation_send_input))

      resolve(&Resolvers.AccountInvitation.send_account_invitation/3)
    end

    @desc "Send an workspace invitation using provided data"
    field :send_workspace_invitations, non_null(:workspace_invitations_send_payload) do
      arg(:data, non_null(:workspace_invitations_send_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.WorkspaceInvitation.send_workspace_invitations/3)
    end

    @desc "Register users with team using provided data"
    field :register_users_with_team, non_null(:register_users_with_team_payload) do
      arg(:where, non_null(:team_where_unique_input))
      arg(:data, non_null(:register_users_with_team_input))

      resolve(&Resolvers.Team.register_users_with_team/3)

      # custom trigger to call associated subscriptions
      middleware(fn resolution, _ ->
        IO.inspect(resolution.value)

        resolution.value
        |> case do
          nil ->
            nil

          %{team: team, team_members: team_members} = value ->
            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              value,
              registered_users_with_team: team.id
            )

            notifications =
              for team_member <- team_members do
                {:registered_users_with_team, team_member.user_id}
              end

            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              value,
              notifications
            )
        end

        resolution
      end)
    end

    @desc "Remove user from team using provided data"
    field :remove_user_from_team, non_null(:remove_user_from_team_payload) do
      arg(:where, non_null(:team_member_where_unique_input))

      resolve(&Resolvers.Team.remove_user_from_team/3)

      # custom trigger to call associated subscriptions
      middleware(fn resolution, _ ->
        IO.inspect(resolution.value)

        resolution.value
        |> case do
          nil ->
            nil

          %{team: team, team_member: team_member} = value ->
            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              value,
              removed_user_from_team: team.id
            )

            Absinthe.Subscription.publish(
              ApiGatewayWeb.Endpoint,
              value,
              removed_user_from_team: team_member.user_id
            )
        end

        resolution
      end)
    end

    @desc "Register a user and a workspace together using provided data"
    field :register_user_from_workspace_invitation,
          non_null(:register_user_from_workspace_invitation_payload) do
      arg(:data, non_null(:register_user_from_workspace_invitation_input))

      resolve(&Resolvers.User.register_user_from_workspace_invitation/3)

      middleware(fn resolution, _ ->
        with %{value: %{user: user}} <- resolution do
          ApiGateway.Models.Account.User.set_last_login_now(user.id)

          Map.update!(resolution, :context, fn ctx ->
            Map.put(ctx, :login_info, %{user_id: user.id})
          end)
        end
      end)
    end

    @desc "Register a user and a workspace together using provided data"
    field :register_user_and_workspace, non_null(:register_user_and_workspace_payload) do
      arg(:data, non_null(:register_user_and_workspace_input))

      resolve(&Resolvers.User.register_user_and_workspace/3)

      middleware(fn resolution, _ ->
        with %{value: %{user: user, token: token}} <- resolution do
          ApiGateway.Models.Account.User.set_last_login_now(user.id)

          Map.update!(resolution, :context, fn ctx ->
            Map.put(ctx, :login_info, %{user_id: user.id, token: token})
          end)
        end
      end)
    end

    @desc "Logs a user into a workspace using provided data"
    field :login_user_with_email_and_password, non_null(:login_user_with_email_and_password) do
      arg(:data, non_null(:login_user_with_email_and_password_input))

      resolve(&Resolvers.User.login_user_with_email_and_password/3)

      middleware(fn resolution, _ ->
        with %{value: %{user: %{id: id}, token: token}} <- resolution do
          ApiGateway.Models.Account.User.set_last_login_now(id)

          Map.update!(resolution, :context, fn ctx ->
            Map.put(ctx, :login_info, %{user_id: id, token: token})
          end)
        end
      end)
    end

    @desc "Logs a user into a workspace using provided data"
    field :logout_user, non_null(:logout_user_payload) do
      resolve(&Resolvers.User.logout_user/3)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)

      middleware(fn resolution, _ ->
        Map.update!(resolution, :context, fn ctx ->
          Map.put(ctx, :logout, true)
        end)
      end)
    end

    @desc "Send a forgot password invitation using provided data"
    field :send_forgot_password_email, non_null(:send_forgot_password_email_payload) do
      arg(:data, non_null(:send_forgot_password_email_input))

      resolve(&Resolvers.ForgotPasswordInvitation.send_forgot_password_invitation/3)
    end

    @desc "Reset account password from reset password email invite"
    field :reset_password_from_forgot_password_invite,
          non_null(:reset_password_from_forgot_password_payload) do
      arg(:data, non_null(:reset_password_from_forgot_password_invite_input))

      resolve(&Resolvers.ForgotPasswordInvitation.reset_password_from_forgot_password_invite/3)

      middleware(fn resolution, _ ->
        with %{value: %{user: user}} <- resolution do
          ApiGateway.Models.Account.User.set_last_login_now(user.id)

          Absinthe.Subscription.publish(
            ApiGatewayWeb.Endpoint,
            user,
            user_password_updated: user.id
          )

          Map.update!(resolution, :context, fn ctx ->
            Map.put(ctx, :login_info, %{user_id: user.id})
          end)
        end
      end)
    end

    @desc "Send an email to help a user find their workspaces"
    field :send_find_my_workspaces_email, non_null(:send_find_my_workspaces_email_payload) do
      arg(:data, non_null(:send_find_my_workspaces_email_input))

      resolve(&Resolvers.FindMyWorkspaces.send_find_my_workspaces_invitation/3)
    end

    @desc "Create new media chat room with provided data"
    field :create_new_media_chat, non_null(:create_new_media_chat_payload) do
      arg(:data, non_null(:create_new_media_chat_input))

      resolve(&Resolvers.MediaChat.create_new_media_chat/3)
    end

    @desc "Invite users to chat room with provided data"
    field :invite_users_to_media_chat, non_null(:invite_users_to_media_chat_payload) do
      arg(:data, non_null(:invite_users_to_media_chat_input))

      resolve(&Resolvers.MediaChat.invite_users_to_media_chat/3)
    end
  end
end
