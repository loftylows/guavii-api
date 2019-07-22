defmodule ApiGatewayWeb.Gql.Schema.MutationInputTypes do
  use Absinthe.Schema.Notation

  input_object :time_zone_input do
    field :name, non_null(:string)
    field :offset, non_null(:string)
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

  input_object :team_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :workspace_id, non_null(:uuid)
  end

  input_object :team_update_input do
    field :title, :string
    field :description, :string
  end

  input_object :project_create_input do
    field :title, non_null(:string)
    field :description, :string
    field :privacy_policy, non_null(:project_privacy_policy)
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
end
