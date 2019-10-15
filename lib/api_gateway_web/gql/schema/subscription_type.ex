defmodule ApiGatewayWeb.Gql.Schema.SubscriptionType do
  use Absinthe.Schema.Notation
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  object :root_subscriptions do
    field :workspace_updated, :workspace do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      trigger(:update_workspace,
        topic: fn workspace ->
          workspace.id
        end
      )
    end

    field :workspace_subdomain_updated, :workspace do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      # Uses custom trigger(s) in mutation
    end

    field :workspace_deleted, :workspace do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      trigger(:delete_workspace,
        topic: fn workspace ->
          workspace.id
        end
      )
    end

    field :user_joined_workspace, :register_user_from_workspace_invitation_payload do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      trigger(:create_user,
        topic: fn result ->
          result.workspace.id
        end
      )
    end

    field :user_updated, :user do
      arg(:where, non_null(:user_subscription_where_input))

      config(fn args, _ ->
        case args.where do
          %{user_id: user_id} ->
            {:ok, topic: user_id}

          %{workspace_id: workspace_id} ->
            {:ok, topic: workspace_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_user,
        topic: fn user ->
          user.id
        end
      )

      trigger(:update_user,
        topic: fn user ->
          user.workspace_id
        end
      )
    end

    field :user_password_updated, :user do
      arg(:user_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.user_id}
      end)

      trigger(:update_user_password,
        topic: fn user ->
          user.id
        end
      )

      # Uses another custom trigger in 'reset_password_from_forgot_password_invite' middleware
    end

    field :user_deleted, :user do
      arg(:user_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.user_id}
      end)

      trigger(:delete_user,
        topic: fn user ->
          user.id
        end
      )
    end

    field :team_updated, :team do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:update_team,
        topic: fn team ->
          team.id
        end
      )
    end

    field :team_deleted, :team do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:delete_team,
        topic: fn team ->
          team.id
        end
      )
    end

    field :team_member_created, :team_member do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:create_team_member,
        topic: fn team_member ->
          team_member.team_id
        end
      )
    end

    field :team_member_updated, :team_member do
      arg(:where, non_null(:team_member_subscription_where_input))

      config(fn args, _ ->
        case args.where do
          %{team_member_id: team_member_id} ->
            {:ok, topic: team_member_id}

          %{team_id: team_id} ->
            {:ok, topic: team_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_team_member,
        topic: fn team_member ->
          team_member.id
        end
      )

      trigger(:update_team_member,
        topic: fn team_member ->
          team_member.team_id
        end
      )
    end

    field :team_member_deleted, :team_member do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:create_team_member,
        topic: fn team_member ->
          team_member.team_id
        end
      )
    end

    field :project_created, :project do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:create_project,
        topic: fn project ->
          project.team_id
        end
      )
    end

    field :project_updated, :project do
      arg(:project_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.project_id}
      end)

      trigger(:update_project,
        topic: fn project ->
          project.id
        end
      )
    end

    field :project_deleted, :project do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.team_id}
      end)

      trigger(:delete_project,
        topic: fn project ->
          project.team_id
        end
      )
    end

    field :kanban_label_created, :kanban_label do
      arg(:kanban_board_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_board_id}
      end)

      trigger(:create_kanban_label,
        topic: fn kanban_label ->
          kanban_label.kanban_board_id
        end
      )
    end

    field :kanban_label_updated, :kanban_label do
      arg(:kanban_board_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_board_id}
      end)

      trigger(:update_kanban_label,
        topic: fn kanban_label ->
          kanban_label.kanban_board_id
        end
      )
    end

    field :kanban_label_deleted, :kanban_label do
      arg(:kanban_board_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_board_id}
      end)

      trigger(:delete_kanban_label,
        topic: fn kanban_label ->
          kanban_label.kanban_board_id
        end
      )
    end

    field :kanban_lane_created, :kanban_lane do
      arg(:kanban_board_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_board_id}
      end)

      trigger(:create_kanban_lane,
        topic: fn kanban_lane ->
          kanban_lane.kanban_board_id
        end
      )
    end

    field :kanban_lane_updated, :update_kanban_lane_payload do
      arg(:where, non_null(:kanban_lane_subscription_where_input))

      config(fn args, _ ->
        case args.where do
          %{kanban_lane_id: kanban_lane_id} ->
            {:ok, topic: kanban_lane_id}

          %{kanban_board_id: kanban_board_id} ->
            {:ok, topic: kanban_board_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_kanban_lane,
        topic: fn kanban_lane ->
          kanban_lane.kanban_lane.id
        end
      )

      trigger(:update_kanban_lane,
        topic: fn kanban_lane ->
          kanban_lane.kanban_lane.kanban_board_id
        end
      )
    end

    field :kanban_lane_deleted, :kanban_lane do
      arg(:kanban_board_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_board_id}
      end)

      trigger(:delete_kanban_lane,
        topic: fn kanban_lane ->
          kanban_lane.kanban_board_id
        end
      )
    end

    field :kanban_card_created, :kanban_card do
      arg(:project_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.project_id}
      end)

      trigger(:create_kanban_card,
        topic: fn kanban_card ->
          kanban_card.project_id
        end
      )
    end

    field :kanban_card_updated, :update_kanban_card_payload do
      arg(:where, non_null(:kanban_card_subscription_where_input))

      config(fn args, _ ->
        case args.where do
          %{kanban_card_id: kanban_card_id} ->
            {:ok, topic: kanban_card_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_kanban_card,
        topic: fn card_update ->
          card_update.kanban_card.id
        end
      )

      trigger(:update_kanban_card,
        topic: fn card_update ->
          card_update.kanban_card.project_id
        end
      )
    end

    field :kanban_card_deleted, :kanban_card do
      arg(:where, non_null(:kanban_card_subscription_where_input))

      config(fn args, _ ->
        case args.where do
          %{kanban_card_id: kanban_card_id} ->
            {:ok, topic: kanban_card_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:delete_kanban_card,
        topic: fn kanban_card ->
          kanban_card.project_id
        end
      )

      trigger(:delete_kanban_card,
        topic: fn kanban_card ->
          kanban_card.id
        end
      )
    end

    field :kanban_card_todo_list_created, :kanban_card_todo_list do
      arg(:kanban_card_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_card_id}
      end)

      trigger(:create_kanban_card_todo_list,
        topic: fn kanban_card_todo_list ->
          kanban_card_todo_list.kanban_card_id
        end
      )
    end

    field :kanban_card_todo_list_updated, :update_kanban_card_todo_list_payload do
      arg(
        :where,
        non_null(:kanban_card_todo_list_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{kanban_card_todo_list_id: kanban_card_todo_list_id} ->
            {:ok, topic: kanban_card_todo_list_id}

          %{kanban_card_id: kanban_card_id} ->
            {:ok, topic: kanban_card_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_kanban_card_todo_list,
        topic: fn payload ->
          payload.kanban_card_todo_list.id
        end
      )

      trigger(:update_kanban_card_todo_list,
        topic: fn payload ->
          payload.kanban_card_todo_list.kanban_card_id
        end
      )
    end

    field :kanban_card_todo_list_deleted, :kanban_card_todo_list do
      arg(:kanban_card_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_card_id}
      end)

      trigger(:delete_kanban_card_todo_list,
        topic: fn kanban_card_todo_list ->
          kanban_card_todo_list.kanban_card_id
        end
      )
    end

    field :kanban_card_todo_created, :kanban_card_todo do
      arg(:kanban_card_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.kanban_card_id}
      end)

      trigger(:create_kanban_card_todo,
        topic: fn kanban_card_todo ->
          kanban_card_todo.card_id
        end
      )
    end

    field :kanban_card_todo_updated, :update_kanban_card_todo_payload do
      arg(
        :where,
        non_null(:kanban_card_todo_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{kanban_card_todo_id: kanban_card_todo_id} ->
            {:ok, topic: kanban_card_todo_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_kanban_card_todo,
        topic: fn payload ->
          payload.kanban_card_todo.id
        end
      )

      trigger(:update_kanban_card_todo,
        topic: fn payload ->
          payload.kanban_card_todo.project_id
        end
      )
    end

    field :kanban_card_todo_deleted, :kanban_card_todo do
      arg(
        :where,
        non_null(:kanban_card_todo_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{kanban_card_todo_id: kanban_card_todo_id} ->
            {:ok, topic: kanban_card_todo_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:delete_kanban_card_todo,
        topic: fn kanban_card_todo ->
          kanban_card_todo.card_id
        end
      )

      trigger(:delete_kanban_card_todo,
        topic: fn kanban_card_todo ->
          kanban_card_todo.project_id
        end
      )
    end

    field :document_created, :document do
      arg(:project_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.project_id}
      end)

      trigger(:create_document,
        topic: fn document ->
          document.project_id
        end
      )
    end

    field :document_info_updated, :document do
      arg(
        :where,
        non_null(:document_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{document_id: document_id} ->
            {:ok, topic: document_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_document,
        topic: fn document ->
          document.id
        end
      )

      trigger(:update_document,
        topic: fn document ->
          document.project_id
        end
      )
    end

    field :document_content_updated, :update_document_content_payload do
      arg(:document_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.document_id}
      end)

      trigger(:update_document_content,
        topic: fn payload ->
          payload.document.id
        end
      )
    end

    field :on_document_selection_changed, :on_document_selection_change_payload do
      arg(:document_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.document_id}
      end)

      trigger(:on_document_selection_change,
        topic: fn payload ->
          payload.id
        end
      )
    end

    field :document_deleted, :document do
      arg(:project_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.project_id}
      end)

      trigger(:delete_document,
        topic: fn document ->
          document.project_id
        end
      )
    end

    field :workspace_ownership_transferred, non_null_list(:user) do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      trigger(:transfer_workspace_ownership,
        topic: fn [user | _tail] ->
          user.workspace_id
        end
      )
    end

    field :user_presence_joined_workspace, :uuid do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      # Uses custom trigger(s) in socket handler
    end

    field :user_presence_left_workspace, :uuid do
      arg(:workspace_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      # Uses custom trigger(s) in socket handler
    end

    field :user_presence_joined_document, :user_presence_joined_document_payload do
      arg(:document_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.document_id}
      end)

      # Uses custom trigger(s) in socket handler
    end

    field :user_presence_left_document, :user_presence_left_document_payload do
      arg(:document_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.document_id}
      end)

      # Uses custom trigger(s) in socket handler
    end

    field :registered_users_with_team, :register_users_with_team_payload do
      arg(
        :where,
        non_null(:registered_users_with_team_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{team_id: team_id} ->
            {:ok, topic: team_id}

          %{user_id: user_id} ->
            {:ok, topic: user_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      # Uses custom trigger(s) in mutation middleware
    end

    field :removed_user_from_team, :remove_user_from_team_payload do
      arg(
        :where,
        non_null(:removed_user_from_team_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{team_id: team_id} ->
            {:ok, topic: team_id}

          %{user_id: user_id} ->
            {:ok, topic: user_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      # Uses custom trigger(s) in mutation middleware
    end

    field :media_chat_call_received, :media_chat_call_received_payload do
      arg(:user_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.user_id}
      end)

      # Uses custom trigger(s) in mutation middleware
    end
  end
end
