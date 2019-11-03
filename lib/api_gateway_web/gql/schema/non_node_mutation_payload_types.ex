defmodule ApiGatewayWeb.Gql.Schema.NonNodeMutationPayloadTypes do
  use Absinthe.Schema.Notation
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  object :login_user_with_email_and_password do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  object :account_invitation_send_payload do
    field :ok, non_null(:boolean)
  end

  object :workspace_invitations_send_payload do
    field :ok, non_null(:boolean)
  end

  object :register_users_with_team_payload do
    field :team, non_null(:team)
    field :team_members, non_null_list(:team_member)
  end

  object :remove_user_from_team_payload do
    field :team, non_null(:team)
    field :team_member, non_null(:team_member)
  end

  object :register_user_from_workspace_invitation_payload do
    field :user, non_null(:user)
    field :workspace, non_null(:workspace)
    field :token, non_null(:string)
  end

  object :register_user_and_workspace_payload do
    field :user, non_null(:user)
    field :workspace, non_null(:workspace)
    field :token, non_null(:string)
  end

  object :logout_user_payload do
    field :ok, non_null(:boolean)
  end

  object :send_forgot_password_email_payload do
    field :ok, non_null(:boolean)
  end

  object :send_find_my_workspaces_email_payload do
    field :ok, non_null(:boolean)
  end

  object :update_kanban_lane_payload do
    field :kanban_lane, non_null(:kanban_lane)
    field :normalized_kanban_lanes, :kanban_lane |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_kanban_card_payload do
    field :kanban_card, non_null(:kanban_card)
    field :normalized_kanban_cards, :kanban_card |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_kanban_card_todo_list_payload do
    field :kanban_card_todo_list, non_null(:kanban_card_todo_list)
    field :normalized_kanban_card_todo_lists, :kanban_card_todo_list |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_kanban_card_todo_payload do
    field :kanban_card_todo, non_null(:kanban_card_todo)
    field :normalized_kanban_card_todos, :kanban_card_todo |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_project_todo_list_payload do
    field :project_todo_list, non_null(:project_todo_list)
    field :normalized_project_todo_lists, :project_todo_list |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_project_todo_payload do
    field :project_todo, non_null(:project_todo)
    field :normalized_project_todos, :project_todo |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_sub_list_payload do
    field :sub_list, non_null(:sub_list)
    field :normalized_sub_lists, :sub_list |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :update_sub_list_item_payload do
    field :sub_list_item, non_null(:sub_list_item)
    field :normalized_sub_list_items, :sub_list_item |> non_null() |> list_of()
    field :just_normalized, non_null(:boolean)
  end

  object :on_document_selection_change_payload do
    field :id, non_null(:uuid)
    field :range, :string
    field :user, non_null(:user)
  end

  object :update_document_content_payload do
    field :user, non_null(:user)
    field :range, non_null(:string)
    field :document, non_null(:document)
  end

  object :reset_password_from_forgot_password_payload do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  object :create_new_media_chat_payload do
    field :chat_id, non_null(:uuid)
  end

  object :invite_users_to_media_chat_payload do
    field :ok, non_null(:boolean)
  end
end
