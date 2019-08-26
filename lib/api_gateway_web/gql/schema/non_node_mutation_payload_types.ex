defmodule ApiGatewayWeb.Gql.Schema.NonNodeMutationPayloadTypes do
  use Absinthe.Schema.Notation

  object :account_invitation_send_payload do
    field :ok, non_null(:boolean)
  end

  object :register_user_and_workspace_payload do
    field :user, non_null(:user)
    field :workspace, non_null(:workspace)
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
    field :ok, non_null(:boolean)
  end
end
