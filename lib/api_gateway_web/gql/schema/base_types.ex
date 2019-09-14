defmodule ApiGatewayWeb.Gql.Schema.BaseTypes do
  require Ecto.Query
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import Ecto.Query, only: [from: 2]

  alias ApiGateway.Models.KanbanBoard
  alias ApiGateway.Models.ProjectListsBoard

  # TODO: fix all connections to use dataloader to stop N+1 queries

  ####################
  # Custom scalars #
  ####################
  scalar :iso_date_time, description: "ISO 8601 date-time string" do
    parse(fn val ->
      case val do
        %Absinthe.Blueprint.Input.Null{} ->
          {:ok, nil}

        _ ->
          case DateTime.from_iso8601(val.value) do
            {:ok, date, _} ->
              {:ok, date}

            _ ->
              :error
          end
      end
    end)

    serialize(fn date_time ->
      DateTime.to_iso8601(date_time)
    end)
  end

  scalar :email, description: "Email address" do
    parse(fn val ->
      IO.inspect(val)

      case val do
        %Absinthe.Blueprint.Input.Null{} ->
          {:ok, nil}

        _ ->
          case ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs.check_email(val) do
            {:ok, email} ->
              {:ok, email}

            _ ->
              :error
          end
      end
    end)

    serialize(& &1)
  end

  scalar :uuid, description: "UUID string" do
    parse(fn val ->
      case val do
        %Absinthe.Blueprint.Input.Null{} ->
          {:ok, nil}

        _ ->
          case Ecto.UUID.cast(val.value) do
            {:ok, uuid} ->
              {:ok, uuid}

            _ ->
              :error
          end
      end
    end)

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
    value(:owner, as: "OWNER")
    value(:admin, as: "ADMIN")
    value(:member, as: "MEMBER")
  end

  enum :user_billing_status do
    value(:active, as: "ACTIVE")
    value(:deactivated, as: "DEACTIVATED")
  end

  enum :team_member_role do
    value(:admin, as: "ADMIN")
    value(:member, as: "MEMBER")
  end

  enum :project_type do
    value(:board, as: "BOARD")
    value(:list, as: "LIST")
  end

  enum :project_status do
    value(:active, as: "ACTIVE")
    value(:archived, as: "ARCHIVED")
  end

  enum :project_privacy_policy do
    value(:public, as: "PUBLIC")
    value(:private, as: "PRIVATE")
  end

  ####################
  # Unions #
  ####################
  union :project_focus_item do
    description("The type of project. Either a kanban or a list board")

    types([:kanban_board, :project_lists_board])

    resolve_type(fn
      %KanbanBoard{}, _ -> :kanban_board
      %ProjectListsBoard{}, _ -> :project_lists_board
    end)

    resolve
  end

  ####################
  # Non-node objects #
  ####################
  object :time_zone do
    field :offset, non_null(:string)
    field :name, non_null(:string)
  end

  object :last_update do
    field :date, non_null(:iso_date_time)

    field :user, :user, resolve: dataloader(ApiGateway.Dataloader)
  end

  object :date_range do
    field :start, non_null(:iso_date_time)
    field :end, non_null(:iso_date_time)
  end

  ####################
  # Connections #
  ####################
  connection node_type: :workspace_invitation do
    field :count, non_null(:integer) do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
    end
  end

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

  connection node_type: :project_todo do
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

  connection node_type: :project_todo_list do
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

  object :workspace_invitation do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :accepted, non_null(:boolean)
    field :workspace_role, non_null(:workspace_member_role)
    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)
    field :invited_by, :user, resolve: dataloader(ApiGateway.Dataloader)

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

    # TODO: write a resolver to check amazon s3 for this method and calculate total space
    field :current_storage_amount, non_null(:integer) do
      resolve(fn _, _, _ -> {:ok, 0} end)
    end

    connection field :members, node_type: :user do
      arg(:where, :user_where_input)

      resolve(fn
        pagination_args, %{source: workspace} ->
          ApiGateway.Models.Account.User
          |> ApiGateway.Models.Account.User.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(workspace_id: ^workspace.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :teams, node_type: :team do
      arg(:where, :team_where_input)

      resolve(fn
        pagination_args, %{source: workspace} ->
          ApiGateway.Models.Team
          |> ApiGateway.Models.Team.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(workspace_id: ^workspace.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :projects, node_type: :project do
      arg(:where, :project_where_input)

      resolve(fn
        pagination_args, %{source: workspace} ->
          ApiGateway.Models.Project
          |> ApiGateway.Models.Project.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(workspace_id: ^workspace.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :workspace_invitations, node_type: :workspace_invitation do
      arg(:where, :workspace_invitation_where_input)

      resolve(fn
        pagination_args, %{source: workspace} ->
          ApiGateway.Models.WorkspaceInvitation
          |> ApiGateway.Models.WorkspaceInvitation.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(workspace_id: ^workspace.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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

    field :is_online, non_null(:boolean) do
      resolve(fn
        %ApiGateway.Models.Account.User{} = user, _, _ ->
          {:ok, ApiGatewayWeb.Gql.Resolvers.User.is_online?(user)}
      end)
    end

    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)

    connection field :teams, node_type: :team do
      arg(:where, :team_where_input)

      resolve(fn
        pagination_args, %{source: user} ->
          query =
            from team_member in ApiGateway.Models.TeamMember,
              join: team in ApiGateway.Models.Team,
              on: team_member.user_id == ^user.id and team_member.team_id == team.id,
              select: team

          query
          |> ApiGateway.Models.Team.add_query_filters(pagination_args[:where])
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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

    connection field :members, node_type: :team_member do
      arg(:where, :team_member_where_input)

      resolve(fn
        pagination_args, %{source: team} ->
          ApiGateway.Models.TeamMember
          |> ApiGateway.Models.TeamMember.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(team_id: ^team.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :projects, node_type: :project do
      arg(:where, :project_where_input)

      resolve(fn
        pagination_args, %{source: team} ->
          ApiGateway.Models.Project
          |> ApiGateway.Models.Project.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(team_id: ^team.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :privacy_policy, non_null(:project_privacy_policy)
    field :project_type, non_null(:project_type)
    field :status, non_null(:project_status)

    field :project_focus_item, non_null(:project_focus_item) do
      resolve(fn project, _, _ ->
        case project do
          %ApiGateway.Models.Project{project_type: "BOARD"} -> {:ok, project.kanban_board}
          %ApiGateway.Models.Project{project_type: "LIST"} -> {:ok, project.lists_board}
        end
      end)
    end

    field :owner, non_null(:team), resolve: dataloader(ApiGateway.Dataloader)
    field :workspace, non_null(:workspace), resolve: dataloader(ApiGateway.Dataloader)
    field :created_by, non_null(:user), resolve: dataloader(ApiGateway.Dataloader)

    connection field :members, node_type: :user do
      arg(:where, :user_where_input)

      resolve(fn
        pagination_args, %{source: project} ->
          Ecto.assoc(project, :members)
          |> ApiGateway.Models.Account.User.add_query_filters(pagination_args[:where])
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :documents, node_type: :document do
      arg(:where, :document_where_input)

      resolve(fn
        pagination_args, %{source: project} ->
          ApiGateway.Models.Document
          |> ApiGateway.Models.Document.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(project_id: ^project.id)
          |> Ecto.Query.preload(:last_update)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :last_update, :last_update

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)

    # TODO: Add resolver
    field :active_users, non_null_list(:user) do
      resolve(fn _, _, _ -> {:ok, []} end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project_lists_board do
    field :id, non_null(:id)

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)

    connection field :lists, node_type: :project_todo_list do
      arg(:where, :project_todo_list_where_input)

      resolve(fn
        pagination_args, %{source: project_lists_board} ->
          ApiGateway.Models.ProjectTodoList
          |> ApiGateway.Models.ProjectTodoList.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(project_lists_board_id: ^project_lists_board.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project_todo_list do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :list_order_rank, non_null(:float)

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)

    connection field :todos, node_type: :project_todo do
      arg(:where, :sub_list_where_input)

      resolve(fn
        pagination_args, %{source: project_todo_list} ->
          ApiGateway.Models.ProjectTodo
          |> ApiGateway.Models.ProjectTodo.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(project_todo_list_id: ^project_todo_list.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :project_todo do
    # interface(:node)

    field :id, non_null(:id)
    add(:title, non_null(:string))
    add(:description, :text)
    add(:completed, non_null(:boolean))
    add(:attachments, non_null_list(:string))
    add(:due_date_range, :due_date_range)
    field :list_order_rank, non_null(:float)

    field :project_todo_list, non_null(:project_todo_list),
      resolve: dataloader(ApiGateway.Dataloader)

    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)
    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)

    connection field :lists, node_type: :sub_list do
      arg(:where, :sub_list_where_input)

      resolve(fn
        pagination_args, %{source: project_todo} ->
          ApiGateway.Models.SubList
          |> ApiGateway.Models.SubList.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(project_todo_id: ^project_todo.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end

  object :sub_list do
    # interface(:node)

    field :id, non_null(:id)
    field :title, non_null(:string)
    field :list_order_rank, non_null(:float)

    field :project_todo, non_null(:project_todo), resolve: dataloader(ApiGateway.Dataloader)

    connection field :lists_items, node_type: :sub_list_item do
      arg(:where, :sub_list_item_where_input)

      resolve(fn
        pagination_args, %{source: sub_list} ->
          ApiGateway.Models.SubListItem
          |> ApiGateway.Models.SubListItem.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(sub_list_id: ^sub_list.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :due_date, :iso_date_time
    field :list_order_rank, non_null(:float)

    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)
    field :sub_list, non_null(:sub_list), resolve: dataloader(ApiGateway.Dataloader)
    field :project, :project, resolve: dataloader(ApiGateway.Dataloader)

    connection field :comments, node_type: :sub_list_item_comment do
      arg(:where, :sub_list_item_comment_where_input)

      resolve(fn
        pagination_args, %{source: sub_list_item} ->
          ApiGateway.Models.SubListItemComment
          |> ApiGateway.Models.SubListItemComment.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(sub_list_item_id: ^sub_list_item.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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

    connection field :lanes, node_type: :kanban_lane do
      arg(:where, :kanban_lane_where_input)

      resolve(fn
        pagination_args, %{source: kanban_board} ->
          ApiGateway.Models.KanbanLane
          |> ApiGateway.Models.KanbanLane.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_board_id: ^kanban_board.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :labels, node_type: :kanban_label do
      arg(:where, :kanban_label_where_input)

      resolve(fn
        pagination_args, %{source: kanban_board} ->
          ApiGateway.Models.KanbanLabel
          |> ApiGateway.Models.KanbanLabel.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_board_id: ^kanban_board.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :list_order_rank, non_null(:float)

    field :kanban_board, non_null(:kanban_board), resolve: dataloader(ApiGateway.Dataloader)

    connection field :cards, node_type: :kanban_card do
      arg(:where, :kanban_card_where_input)

      resolve(fn
        pagination_args, %{source: kanban_lane} ->
          ApiGateway.Models.KanbanCard
          |> ApiGateway.Models.KanbanCard.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_lane_id: ^kanban_lane.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :completed, non_null(:boolean)
    field :due_date_range, :date_range
    field :attachments, non_null_list(:string)
    field :list_order_rank, non_null(:float)

    field :last_update, :last_update

    field :kanban_lane, non_null(:kanban_lane), resolve: dataloader(ApiGateway.Dataloader)
    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)
    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)

    connection field :todo_lists, node_type: :kanban_card_todo_list do
      arg(:where, :kanban_card_todo_list_where_input)

      resolve(fn
        pagination_args, %{source: kanban_card} ->
          ApiGateway.Models.KanbanCardTodoList
          |> ApiGateway.Models.KanbanCardTodoList.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_card_id: ^kanban_card.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :active_labels, node_type: :kanban_label do
      arg(:where, :kanban_label_where_input)

      resolve(fn
        pagination_args, %{source: kanban_card} ->
          query =
            from active_labels in "kanban_card_active_labels",
              join: kanban_label in ApiGateway.Models.KanbanLabel,
              on: kanban_label.id == active_labels.kanban_label_id,
              join: kanban_card in ApiGateway.Models.KanbanCard,
              on:
                kanban_card.id == active_labels.kanban_card_id and
                  kanban_card.id == ^kanban_card.id,
              select: kanban_label

          query
          |> ApiGateway.Models.KanbanLabel.add_query_filters(pagination_args[:where])
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
      end)
    end

    connection field :comments, node_type: :kanban_card_comment do
      arg(:where, :kanban_card_comment_where_input)

      resolve(fn
        pagination_args, %{source: kanban_card} ->
          ApiGateway.Models.KanbanCardComment
          |> ApiGateway.Models.KanbanCardComment.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_card_id: ^kanban_card.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :list_order_rank, non_null(:float)

    field :kanban_card, non_null(:kanban_card), resolve: dataloader(ApiGateway.Dataloader)

    connection field :todos, node_type: :kanban_card_todo do
      arg(:where, :kanban_card_todo_where_input)

      resolve(fn
        pagination_args, %{source: kanban_card_todo_list} ->
          ApiGateway.Models.KanbanCardTodo
          |> ApiGateway.Models.KanbanCardTodo.add_query_filters(pagination_args[:where])
          |> Ecto.Query.where(kanban_card_todo_list_id: ^kanban_card_todo_list.id)
          |> Absinthe.Relay.Connection.from_query(&ApiGateway.Repo.all/1, pagination_args)
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
    field :list_order_rank, non_null(:float)

    field :kanban_card_todo_list, non_null(:kanban_card_todo_list),
      name: "todo_list",
      resolve: dataloader(ApiGateway.Dataloader)

    field :card, non_null(:kanban_card), resolve: dataloader(ApiGateway.Dataloader)
    field :project, non_null(:project), resolve: dataloader(ApiGateway.Dataloader)
    field :assigned_to, :user, resolve: dataloader(ApiGateway.Dataloader)

    field :inserted_at, non_null(:iso_date_time), name: "created_at"
    field :updated_at, non_null(:iso_date_time)
  end
end
