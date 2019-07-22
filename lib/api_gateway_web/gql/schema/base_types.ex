defmodule ApiGatewayWeb.Gql.Schema.BaseTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  ####################
  # Custom scalars #
  ####################
  scalar :iso_date_time, description: "ISO 8601 date-time string" do
    parse(fn val ->
      case DateTime.from_iso8601(val.value) do
        {:ok, date, _} ->
          {:ok, date}

        _ ->
          :error
      end
    end)

    serialize(&DateTime.to_iso8601(&1))
  end

  scalar :email, description: "Email address" do
    parse(&ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs.check_email(&1))
    serialize(& &1)
  end

  scalar :uuid, description: "UUID string" do
    parse(&Ecto.UUID.cast(&1.value))
    serialize(& &1)
  end

  ####################
  # Interfaces #
  ####################
  interface :node do
    field :id, non_null(:id)
  end

  ####################
  # Enums #
  ####################
  enum :workspace_member_role do
    value(:primary_owner, as: "primary_owner")
    value(:owner, as: "owner")
    value(:admin, as: "admin")
    value(:member, as: "member")
  end

  enum :user_billing_status do
    value(:active, as: "active")
    value(:deactivated, as: "deactivated")
  end

  enum :team_member_role do
    value(:admin, as: "admin")
    value(:member, as: "member")
  end

  enum :project_type do
    value(:board, as: "board")
    value(:list, as: "list")
  end

  enum :project_status do
    value(:active, as: "active")
    value(:archived, as: "archived")
  end

  enum :project_privacy_policy do
    value(:public, as: "public")
    value(:private, as: "private")
  end

  ####################
  # Unions #
  ####################
  # TODO: fix this definition by providing a proper resolve function
  union :project_focus_item do
    description("The type of project. Either a board or a list")

    types([:kanban_board, :project_todo_list])

    resolve_type(fn
      %{lanes: _}, _ -> :kanban_board
      %{lists: _}, _ -> :project_todo_list
    end)
  end

  ####################
  # Non-node objects #
  ####################
  object :time_zone do
    field :offset, non_null(:string)
    field :billing_status, non_null(:string)
  end

  object :document_last_update do
    field :date, non_null(:iso_date_time)
    field :user, non_null(:user)
  end

  object :date_range do
    field :start, :iso_date_time
    field :end, :iso_date_time
  end

  ####################
  # Input objects #
  ####################
  input_object :date_range_input do
    field :start, non_null(:iso_date_time)
    field :end, non_null(:iso_date_time)
  end

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

  input_object :check_user_invite_token_valid_input do
    field :token, non_null(:string)
    field :email, non_null(:email)
  end

  input_object :find_my_workspaces_input do
    field :token, non_null(:string)
    field :email_connected_to_invitation, non_null(:email)
  end

  ########## input filters ##########
  input_object :user_where_unique_input do
    field :id, non_null(:string)
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
  end

  @desc "Must provide either an ID or a workspace subdomain"
  input_object :workspace_where_unique_input do
    field :id, :uuid
    field :workspace_subdomain, :string
  end

  input_object :workspace_where_input do
    field :id_in, list_of(:uuid)
    field :workspace_subdomain_in, list_of(:string)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :team_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :team_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :project_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :project_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :team_member_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :team_member_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :team_id_in, list_of(:uuid)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
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
  end

  input_object :sub_list_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :sub_list_item_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_item_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :project_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :sub_list_item_comment_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :sub_list_item_comment_where_input do
    field :id_in, list_of(:uuid)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_lane_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_lane_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_label_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_label_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :color, :string
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_card_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :active_label_id_in, list_of(:uuid)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_card_comment_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_comment_where_input do
    field :id_in, list_of(:uuid)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_card_todo_list_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_todo_list_where_input do
    field :id_in, list_of(:uuid)
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  input_object :kanban_card_todo_where_unique_input do
    field :id, non_null(:uuid)
  end

  input_object :kanban_card_todo_where_input do
    field :id_in, list_of(:uuid)
    field :title_contains, :string
    field :completed, :boolean
    field :project_id, :uuid
    field :created_at, :iso_date_time
    field :created_at_gte, :iso_date_time
    field :created_at_lte, :iso_date_time
  end

  ####################
  # Connections #
  ####################
  connection node_type: :workspace do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :user do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :team_member do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :team do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :project do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :document do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :sub_list do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :sub_list_item do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :sub_list_item_comment do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_lane do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_label do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_card do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_card_comment do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_card_todo_list do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  connection node_type: :kanban_card_todo do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

  ####################
  # Nodes #
  ####################
  object :account_invitation do
    # interface(:node)

    field :id, non_null(:id)
    field :email, non_null(:string)
    field :invitation_token_hashed, non_null(:string)
    field :accepted, non_null(:boolean)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :workspace_invitation do
    # interface(:node)

    field :id, non_null(:id)
    field :email, non_null(:string)
    field :invitation_token_hashed, non_null(:string)
    field :accepted, non_null(:boolean)

    field :workspace, non_null(:workspace)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :forgot_password_invitation do
    # interface(:node)

    field :id, non_null(:id)
    field :token_hashed, non_null(:string)
    field :accepted, non_null(:boolean)
    field :userId, non_null(:string)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :find_my_workspaces_invitation do
    # interface(:node)

    field :id, non_null(:id)
    field :email, non_null(:string)
    field :token_hashed, non_null(:string)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :workspace do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :workspace_subdomain, non_null(:string)
    field :description, :string
    field :storage_cap, non_null(:integer)
    field :current_storage_amount, non_null(:integer)

    # TODO: Add resolver
    connection field :members, node_type: :user do
      arg(:where, :user_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :teams, node_type: :team do
      arg(:where, :team_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :projects, node_type: :project do
      arg(:where, :project_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :user do
    # interface(:node)

    field :id, non_null(:id)
    field :full_name, non_null(:string)
    field :email, non_null(:email)
    field :profile_description, :string
    field :profile_role, :string
    field :phone_number, :string
    field :birthday, :iso_date_time
    field :location, :string
    field :time_zone, :time_zone
    field :profile_pic_url, :string
    field :last_login, :iso_date_time
    field :workspace_role, non_null(:workspace_member_role)
    field :billing_status, non_null(:user_billing_status)

    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :teams, node_type: :team do
      arg(:where, :team_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :team_member do
    # interface(:node)

    field :id, non_null(:id)
    field :role, non_null(:team_member_role)

    field :user, non_null(:user), resolve: dataloader(ApiGateway.Dataloader)
    field :team, non_null(:team), resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :team do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string

    # field :workspace, non_null(:workspace) do
    # resolve(&ApiGatewayWeb.Gql.Resolvers.Team.get_team_workspace/3)
    # end

    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :members, node_type: :team_member do
      arg(:where, :team_member_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :projects, node_type: :project do
      arg(:where, :project_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, non_null(:string)
    field :privacy_policy, non_null(:project_privacy_policy)
    field :project_focus_item, non_null(:project_focus_item)
    field :project_type, non_null(:project_type)
    field :status, non_null(:project_status)

    field :owner, non_null(:team), resolve: dataloader(ApiGateway.Dataloader)
    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)
    field :created_by, non_null(:user), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :members, node_type: :user do
      arg(:where, :user_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :documents, node_type: :document do
      arg(:where, :document_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :document do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :content, non_null(:string)
    field :is_pinned, non_null(:boolean)
    field :last_update, :document_last_update

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :active_users, node_type: :user do
      arg(:where, :user_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project_todo_list do
    # interface(:node)

    field :id, non_null(:id)

    field :project, non_null(:string), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :lists, node_type: :sub_list do
      arg(:where, :sub_list_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :sub_list do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)

    field :project_todo_list, non_null(:project_todo_list),
      resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :lists_items, node_type: :sub_list_item do
      arg(:where, :sub_list_item_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :sub_list_item do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :completed, :boolean
    field :attachments, non_null_list(:string)
    field :due_date_range, :date_range

    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)
    field :sub_list, non_null(:sub_list), resolve: dataloader(ApiGateway.Dataloader)
    field :project, :project, resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :comments, node_type: :sub_list_item_comment do
      arg(:where, :sub_list_item_comment_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :sub_list_item_comment do
    # interface(:node)

    field :id, non_null(:id)
    field :content, non_null(:string)
    field :edited, non_null(:boolean)

    field :by, :user, resolve: dataloader(ApiGateway.Dataloader)
    field :sub_list_item, non_null(:sub_list_item), resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_board do
    # interface(:node)

    field :id, non_null(:id)

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :lanes, node_type: :kanban_lane do
      arg(:where, :kanban_lane_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :labels, node_type: :kanban_label do
      arg(:where, :kanban_label_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_label do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :color, non_null(:string)

    field :kanban_board, non_null(:kanban_board), resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_lane do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :lane_color, non_null(:string)

    field :kanban_board, non_null(:kanban_board), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :cards, node_type: :kanban_card do
      arg(:where, :kanban_card_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_card do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :completed, non_null(:string)
    field :due_date_range, :date_range
    field :attachments, non_null_list(:string)

    field :kanban_lane, non_null(:kanban_lane), resolve: dataloader(ApiGateway.Dataloader)
    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)
    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :todo_lists, node_type: :kanban_card_todo_list do
      arg(:where, :kanban_card_todo_list_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :active_labels, node_type: :kanban_label do
      arg(:where, :kanban_label_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    # TODO: Add resolver
    connection field :comments, node_type: :kanban_card_comment do
      arg(:where, :kanban_card_comment_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_card_comment do
    # interface(:node)

    field :id, non_null(:id)
    field :content, non_null(:string)
    field :edited, non_null(:boolean)

    field :kanban_card, non_null(:kanban_card), resolve: dataloader(ApiGateway.Dataloader)
    field :by, :user, resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_card_todo_list do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)

    field :kanban_card, non_null(:kanban_card), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    connection field :todos, node_type: :kanban_card_todo do
      arg(:where, :kanban_card_todo_where_input)

      resolve(fn
        _pagination_args, %{source: _workspace} ->
          nil
          # ... return {:ok, a_connection}
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :kanban_card_todo do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :completed, non_null(:boolean)
    field :due_date, :iso_date_time

    field :todo_list, non_null(:kanban_card_todo_list), resolve: dataloader(ApiGateway.Dataloader)
    field :card, non_null(:kanban_card), resolve: dataloader(ApiGateway.Dataloader)
    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)
    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end
end
