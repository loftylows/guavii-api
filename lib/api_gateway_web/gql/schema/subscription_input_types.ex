defmodule ApiGatewayWeb.Gql.Schema.SubscriptionInputTypes do
  use Absinthe.Schema.Notation

  input_object :kanban_lane_subscription_where_input do
    field :kanban_lane_id, :uuid
    field :kanban_board_id, :uuid
  end

  input_object :kanban_card_subscription_where_input do
    field :kanban_card_id, :uuid
    field :project_id, :uuid
  end

  input_object :kanban_card_todo_list_subscription_where_input do
    field :kanban_card_todo_list_id, :uuid
    field :kanban_card_id, :uuid
  end

  input_object :kanban_card_todo_subscription_where_input do
    field :kanban_card_todo_id, :uuid
    field :project_id, :uuid
  end

  input_object :team_member_subscription_where_input do
    field :team_member_id, :uuid
    field :team_id, :uuid
  end

  input_object :document_subscription_where_input do
    field :document_id, :uuid
    field :project_id, :uuid
  end
end
