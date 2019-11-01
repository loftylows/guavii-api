defmodule ApiGatewayWeb.Gql.Schema.QueryInputTypes do
  use Absinthe.Schema.Notation

  input_object :check_email_unused_in_workspace_input do
    field :email, non_null(:email)
    field :workspace_id, non_null(:uuid)
  end

  input_object :check_logged_into_workspace_input do
    field :subdomain, non_null(:string)
  end

  input_object :check_workspace_subdomain_available_input do
    field :subdomain, non_null(:string)
  end

  input_object :check_workspace_exists_by_subdomain_input do
    field :subdomain, non_null(:string)
  end

  input_object :check_user_invite_token_valid_input do
    field :token, non_null(:string)
    field :email, non_null(:email)
  end

  input_object :find_my_workspaces_input do
    field :token, non_null(:string)
    field :email_connected_to_invitation, non_null(:email)
  end

  ########## input filters ##########
  input_object :workspace_invitation_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :workspace_invitation_where_input do
    field :id_in, list_of(:uuid)
    field :accepted, :boolean
    field :workspace_id, :uuid
    field :invited_by_id, :uuid
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
  end

  input_object :user_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :user_where_input do
    field :id_in, list_of(:uuid)
    field :email_in, list_of(:email)
    field :full_name_contains, :string
    field :billing_status, :user_billing_status
    field :workspace_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :last_login, :iso_date_time
    field :last_login_gte, :iso_date_time
    field :last_login_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :users_order_by_input
  end

  input_object :users_order_by_input do
    field :order_by, non_null(:users_order_by)
    field :direction, non_null(:order_by_direction)
  end

  @desc "Must provide either an ID or a workspace subdomain"
  input_object :workspace_where_unique_input do
    field :id, :uuid
    field :workspace_subdomain, :string
  end

  input_object :workspace_where_unique_options_input do
    field :include_archived_matches, :boolean
  end

  input_object :workspace_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :workspace_subdomain_in, list_of(:string)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :workspaces_order_by_input
  end

  input_object :workspaces_order_by_input do
    field :order_by, non_null(:workspaces_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :team_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :team_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :workspace_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :teams_order_by_input
  end

  input_object :teams_order_by_input do
    field :order_by, non_null(:teams_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :project_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :project_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :uuid
    field :project_type, :project_type
    field :status, :project_status
    field :privacy_policy, :project_privacy_policy
    field :workspace_id, :uuid
    field :owner_id, :uuid
    field :created_by_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :projects_order_by_input
  end

  input_object :projects_order_by_input do
    field :order_by, non_null(:projects_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :team_member_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :team_member_where_input do
    field :id_in, list_of(:uuid)
    field :role, :team_member_role
    field :team_id, :uuid
    field :user_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :team_members_order_by_input
  end

  input_object :team_members_order_by_input do
    field :order_by, non_null(:team_members_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :document_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :document_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :project_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :documents_order_by_input
  end

  input_object :documents_order_by_input do
    field :order_by, non_null(:documents_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :project_todo_list_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :project_todo_list_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :project_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :project_todo_lists_order_by_input
  end

  input_object :project_todo_lists_order_by_input do
    field :order_by, non_null(:project_todo_lists_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :project_todo_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :project_todo_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :project_id, :uuid
    field :todo_list_id, :uuid
    field :assigned_to_id, :uuid
    field :has_due_date, :boolean
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :project_todos_order_by_input
  end

  input_object :project_todos_order_by_input do
    field :order_by, non_null(:project_todos_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :sub_list_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :project_todo_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :sub_lists_order_by_input
  end

  input_object :sub_lists_order_by_input do
    field :order_by, non_null(:sub_lists_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :sub_list_item_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_item_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :assigned_to_id, :uuid
    field :project_id, :uuid
    field :sub_list_id, :uuid
    field :assigned_to, :uuid
    field :has_due_date, :boolean
    field :due_date, :iso_date_time
    field :due_date_gte, :iso_date_time
    field :due_date_lte, :iso_date_time
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :sub_list_items_order_by_input
  end

  input_object :sub_list_items_order_by_input do
    field :order_by, non_null(:sub_list_items_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :sub_list_item_comment_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_item_comment_where_input do
    field :id_in, list_of(:uuid)
    field :edited, :boolean
    field :sub_list_item_id, :uuid
    field :by_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :sub_list_item_comments_order_by_input
  end

  input_object :sub_list_item_comments_order_by_input do
    field :order_by, non_null(:sub_list_item_comments_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_lane_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_lane_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :lane_color, :string
    field :kanban_board_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_lanes_order_by_input
  end

  input_object :kanban_lanes_order_by_input do
    field :order_by, non_null(:kanban_lanes_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_label_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_label_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :color, :string
    field :kanban_board_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_labels_order_by_input
  end

  input_object :kanban_labels_order_by_input do
    field :order_by, non_null(:kanban_labels_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_card_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :assigned_to_id, :uuid
    field :kanban_lane_id, :uuid
    field :has_due_date, :boolean
    field :project_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_cards_order_by_input
  end

  input_object :kanban_cards_order_by_input do
    field :order_by, non_null(:kanban_cards_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_card_comment_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_comment_where_input do
    field :id_in, list_of(:uuid)
    field :edited, :boolean
    field :kanban_card_id, :uuid
    field :by_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_card_comments_order_by_input
  end

  input_object :kanban_card_comments_order_by_input do
    field :order_by, non_null(:kanban_card_comments_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_card_todo_list_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_todo_list_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :kanban_card_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_card_todo_lists_order_by_input
  end

  input_object :kanban_card_todo_lists_order_by_input do
    field :order_by, non_null(:kanban_card_todo_lists_order_by)
    field :direction, non_null(:order_by_direction)
  end

  input_object :kanban_card_todo_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_todo_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :has_due_date, :boolean
    field :assigned_to_id, :uuid
    field :kanban_card_id, :uuid
    field :kanban_card_todo_list_id, :uuid
    field :project_id, :uuid
    field :due_date, :iso_date_time
    field :due_date_gte, :iso_date_time
    field :due_date_lte, :iso_date_time
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
    field :distinct, :boolean
    field :order_by, :kanban_card_todos_order_by_input
  end

  input_object :kanban_card_todos_order_by_input do
    field :order_by, non_null(:kanban_card_todos_order_by)
    field :direction, non_null(:order_by_direction)
  end

  ####################
  # Non-node type input queries #
  ####################
  input_object :find_my_workspaces_input do
    field :email, non_null(:string)
    field :token, non_null(:string)
  end

  input_object :check_user_can_enter_media_chat_input do
    field :chat_id, non_null(:uuid)
  end

  input_object :get_media_chat_info_input do
    field :chat_id, non_null(:uuid)
  end

  input_object :check_socket_token_valid_input do
    field :token, non_null(:string)
  end

  input_object :search_workspace_users_input do
    field :workspace_id, non_null(:uuid)
    field :search_string, non_null(:string)
    field :order_by, :users_order_by_input
  end
end
