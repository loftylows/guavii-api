defmodule ApiGatewayWeb.Gql.Schema.SubscriptionType do
  use Absinthe.Schema.Notation

  object :root_subscriptions do
    field :workspace_updated, :workspace do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.workspace_id}
      end)

      trigger(:update_workspace,
        topic: fn workspace ->
          workspace.id
        end
      )
    end

    field :user_updated, :user do
      arg(:team_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.user_id}
      end)

      trigger(:update_user,
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

    field :team_member_updated, :team_member do
      arg(:team_member_subscription_where_input, non_null(:team_member_subscription_where_input))

      config(fn args, _ ->
        case args.kanban_lane_subscription_where_input do
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

    field :kanban_card_todo_list_updated, :update_kanban_card_todo_list_payload do
      arg(
        :where,
        non_null(:kanban_card_todo_list_subscription_where_input)
      )

      config(fn args, _ ->
        case args.where do
          %{kanban_card_todo_list_id: kanban_card_todo_list_id} ->
            {:ok, topic: kanban_card_todo_list_id}

          %{project_id: project_id} ->
            {:ok, topic: project_id}

          _ ->
            {:error, "User input error."}
        end
      end)

      trigger(:update_kanban_card_todo_list,
        topic: fn kanban_card_todo_list ->
          kanban_card_todo_list.kanban_card_todo_list.id
        end
      )

      trigger(:update_kanban_card_todo_list,
        topic: fn kanban_card_todo_list ->
          kanban_card_todo_list.kanban_card_todo_list.kanban_card_id
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
        topic: fn kanban_card_todo ->
          kanban_card_todo.kanban_card_todo.id
        end
      )

      trigger(:update_kanban_card_todo,
        topic: fn kanban_card_todo ->
          kanban_card_todo.kanban_card_todo.project_id
        end
      )
    end

    field :document_updated, :document do
      arg(:document_id, non_null(:uuid))

      config(fn args, _ ->
        {:ok, topic: args.document_id}
      end)

      trigger(:update_document,
        topic: fn document ->
          document.id
        end
      )
    end
  end
end
