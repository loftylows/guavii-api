defmodule ApiGatewayWeb.Gql.Schema.MutationInputTypes do
  use Absinthe.Schema.Notation

  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]

  input_object :list_item_position_input do
    field :prev_item_rank, :float
    field :next_item_rank, :float
  end

  input_object :time_zone_input do
    field :name, non_null(:string)
    field :offset, non_null(:string)
  end

  input_object :workspace_invitation_update_input do
    field :workspace_role, :workspace_member_role
  end

  input_object :workspace_create_input do
    field :title, non_null(:string)
    field :workspace_subdomain, non_null(:string)
    field :description, :string
  end

  input_object :workspace_update_input do
    field :title, :string
    field :workspace_subdomain, :string
    field :description, :string
  end

  input_object :transfer_workspace_ownership_input do
    field :owner_id, non_null(:uuid)
    field :member_id, non_null(:uuid)
    field :password, non_null(:string)
  end

  input_object :user_create_input do
    field :email, non_null(:string)
    field :full_name, non_null(:string)
    field :profile_description, :string
    field :profile_role, :string
    field :phone_number, :string
    field :location, :string
    field :birthday, :iso_date_time
    field :profile_pic_url, :string
    field :time_zone, :time_zone_input
    field :password, non_null(:string)
    field :workspace_id, non_null(:uuid)
  end

  input_object :user_update_input do
    field :email, :string
    field :full_name, :string
    field :profile_description, :string
    field :profile_role, :string
    field :phone_number, :string
    field :location, :string
    field :birthday, :iso_date_time
    field :profile_pic_url, :string
    field :time_zone, :time_zone_input
    field :workspace_role, :workspace_member_role
    field :billing_status, :user_billing_status
  end

  input_object :user_update_password_input do
    field :old_password, non_null(:string)
    field :new_password, non_null(:string)
  end

  input_object :team_create_input do
    field :title, non_null(:string)
    field :description, :string
  end

  input_object :team_update_input do
    field :title, :string
    field :description, :string
  end

  input_object :team_member_update_input do
    field :role, :team_member_role
  end

  input_object :project_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :privacy_policy, :project_privacy_policy
    field :project_type, non_null(:project_type)
    field :team_id, non_null(:uuid)
  end

  input_object :project_update_input do
    field :title, :string
    field :description, :string
    field :privacy_policy, :project_privacy_policy
    field :project_type, :project_type
    field :status, :project_status
  end

  input_object :document_create_input do
    field :title, non_null(:string)
    field :content, :string
    field :is_pinned, :boolean
    field :project_id, non_null(:uuid)
  end

  input_object :document_update_input do
    field :title, :string
    field :is_pinned, :boolean
  end

  input_object :document_update_content_input do
    field :content, non_null(:string)
    field :range, non_null(:string)
  end

  input_object :on_document_selection_change_input do
    field :range, :string
  end

  input_object :project_todo_list_create_input do
    field :title, non_null(:string)
    field :project_id, non_null(:uuid)
    field :project_lists_board_id, non_null(:uuid)
  end

  input_object :project_todo_list_update_input do
    field :title, :string
  end

  input_object :project_todo_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :completed, :boolean
    field :attachments, :string |> non_null() |> list_of()
    field :due_date_range, :date_range_input

    field :project_todo_list_id, non_null(:uuid)
    field :project_id, non_null(:uuid)
    field :user_id, :uuid
  end

  input_object :project_todo_update_input do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, :string |> non_null() |> list_of()
    field :due_date_range, :date_range_input

    field :project_todo_list_id, :uuid
    field :user_id, :uuid
  end

  input_object :sub_list_create_input do
    field :title, non_null(:string)
    field :project_todo_id, non_null(:uuid)
  end

  input_object :sub_list_update_input do
    field :title, :string
  end

  input_object :sub_list_item_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :completed, :boolean
    field :due_date, :iso_date_time

    field :sub_list_id, non_null(:uuid)
    field :project_id, non_null(:uuid)
    field :user_id, :uuid
  end

  input_object :sub_list_item_update_input do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :due_date, :iso_date_time

    field :sub_list_id, :uuid
    field :project_id, :uuid
    field :user_id, :uuid
  end

  input_object :sub_list_item_comment_create_input do
    field :content, non_null(:string)
    field :sub_list_item_id, non_null(:uuid)
  end

  input_object :sub_list_item_comment_update_input do
    field :content, :string
  end

  input_object :kanban_label_create_input do
    field :title, non_null(:string)
    field :color, non_null(:string)
    field :kanban_board_id, non_null(:uuid)
  end

  input_object :kanban_label_update_input do
    field :title, :string
    field :color, :string
  end

  input_object :kanban_lane_create_input do
    field :title, non_null(:string)
    field :lane_color, non_null(:string)
    field :kanban_board_id, non_null(:uuid)
  end

  input_object :kanban_lane_update_input do
    field :title, :string
    field :lane_color, :string
  end

  input_object :kanban_card_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :completed, :boolean
    field :attachments, :string |> non_null() |> list_of()
    field :due_date_range, :date_range_input

    field :kanban_lane_id, non_null(:uuid)
    field :project_id, non_null(:uuid)
    field :user_id, :uuid
  end

  input_object :kanban_card_update_input do
    field :title, :string
    field :description, :string
    field :completed, :boolean
    field :attachments, :string |> non_null() |> list_of()
    field :due_date_range, :date_range_input
    field :active_labels, :uuid |> non_null() |> list_of()

    field :kanban_lane_id, :uuid
    field :user_id, :uuid
  end

  input_object :kanban_card_comment_create_input do
    field :content, non_null(:string)
    field :kanban_card_id, non_null(:uuid)
  end

  input_object :kanban_card_comment_update_input do
    field :content, :string
  end

  input_object :kanban_card_todo_list_create_input do
    field :title, non_null(:string)
    field :kanban_card_id, non_null(:uuid)
  end

  input_object :kanban_card_todo_list_update_input do
    field :title, :string
  end

  input_object :kanban_card_todo_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :completed, :boolean
    field :due_date, :iso_date_time

    field :kanban_card_todo_list_id, non_null(:uuid)
    field :card_id, non_null(:uuid)
    field :project_id, non_null(:uuid)
    field :user_id, :uuid
  end

  input_object :kanban_card_todo_update_input do
    field :title, :string
    field :completed, :boolean
    field :due_date, :iso_date_time

    field :kanban_card_todo_list_id, :uuid
    field :card_id, :uuid
    field :project_id, :uuid
    field :user_id, :uuid
  end

  ######################
  # Non-node mutations #
  ######################

  input_object :account_invitation_send_input do
    field :email, :email
  end

  input_object :register_user_with_team_info_input do
    field :email, non_null(:email)
    field :team_role, :team_member_role
  end

  input_object :register_users_with_team_input do
    field :info_items, non_null_list(:register_user_with_team_info_input)
  end

  input_object :workspace_user_invitation_info_input do
    field :email, non_null(:email)
    field :name, non_null(:string)
    field :workspace_role, :workspace_member_role
  end

  input_object :workspace_invitations_send_input do
    field :invitation_info_items, non_null_list(:workspace_user_invitation_info_input)
  end

  input_object :register_user_from_workspace_invitation_input do
    field :full_name, non_null(:string)
    field :password, non_null(:string)

    field :token, non_null(:string)
    field :encoded_email_connected_to_invitation, non_null(:string)
  end

  input_object :create_user_with_workspace_registration_input do
    field :full_name, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :create_workspace_with_user_registration_input do
    field :title, non_null(:string)
    field :subdomain, non_null(:string)
  end

  input_object :register_user_and_workspace_input do
    field :token, non_null(:string)
    field :encoded_email_connected_to_invitation, non_null(:string)

    field :create_user_with_workspace_registration_input,
          non_null(:create_user_with_workspace_registration_input)

    field :create_workspace_with_user_registration_input,
          non_null(:create_workspace_with_user_registration_input)
  end

  input_object :login_user_with_email_and_password_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :send_forgot_password_email_input do
    field :email, non_null(:string)
  end

  input_object :reset_password_from_forgot_password_invite_input do
    field :user_id, non_null(:uuid)
    field :token, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :send_find_my_workspaces_email_input do
    field :email, non_null(:string)
  end

  input_object :create_new_media_chat_input do
    field :invitees, non_null_list(:uuid)
  end
end
