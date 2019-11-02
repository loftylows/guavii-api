defmodule ApiGatewayWeb.Gql.Schema.QueryType do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  alias ApiGatewayWeb.Gql.Resolvers

  object :root_queries do
    @desc "Get a workspace using criteria"
    field :workspace, :workspace do
      arg(:where, non_null(:workspace_where_unique_input))
      arg(:where_options, :workspace_where_unique_options_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Workspace.get_workspace/3)
    end

    @desc "Get all workspaces, optionally filtering"
    field :workspaces, non_null_list(:workspace) do
      arg(:where, :workspace_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Workspace.get_workspaces/3)
    end

    @desc "Get a user using criteria"
    field :user, :user do
      arg(:where, non_null(:user_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.get_user/3)
    end

    # TODO: Remove this! No customer user should be able to search get all users
    @desc "Get all users, optionally filtering"
    field :users, non_null_list(:user) do
      arg(:where, :user_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.get_users/3)
    end

    @desc "Get workspace users, optionally filtering"
    connection field :workspace_users, node_type: :user do
      arg(:where, :user_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.workspace_users/2)
    end

    @desc "Search workspace users by name or email"
    connection field :search_workspace_users, node_type: :user do
      arg(:where, non_null(:search_workspace_users_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.search_workspace_users/2)
    end

    @desc "Get a team using criteria"
    field :team, :team do
      arg(:where, non_null(:team_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Team.get_team/3)
    end

    @desc "Get all teams, optionally filtering"
    field :teams, non_null_list(:team) do
      arg(:where, :team_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Team.get_teams/3)
    end

    @desc "Get a project using criteria"
    field :project, :project do
      arg(:where, non_null(:project_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Project.get_project/3)
    end

    @desc "Get a document using criteria"
    field :document, :document do
      arg(:where, non_null(:document_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.get_document/3)
    end

    @desc "Get all documents, optionally filtering"
    field :documents, non_null_list(:document) do
      arg(:where, :document_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.Document.get_documents/3)
    end

    @desc "Get a kanban card using criteria"
    field :kanban_card, :kanban_card do
      arg(:where, non_null(:kanban_card_where_unique_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCard.get_kanban_card/3)
    end

    @desc "Get a kanban cards using criteria"
    field :kanban_cards, non_null_list(:kanban_card) do
      arg(:where, non_null(:kanban_card_where_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCard.get_kanban_cards/3)
    end

    @desc "Get a kanban card todos using criteria"
    field :kanban_card_todos, non_null_list(:kanban_card_todo) do
      arg(:where, non_null(:kanban_card_todo_where_input))

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.KanbanCardTodo.get_kanban_card_todos/3)
    end

    ####################
    # Other queries #
    ####################
    @desc "Check whether the provided email is unused in the workspace"
    field :check_email_unused_in_workspace, non_null(:boolean) do
      arg(:data, non_null(:check_email_unused_in_workspace_input))

      resolve(&Resolvers.User.check_user_email_unused_in_workspace/3)
    end

    @desc "Check logged into workspace having provided subdomain"
    field :check_logged_into_workspace, non_null(:boolean) do
      arg(:data, non_null(:check_logged_into_workspace_input))

      resolve(fn _, _, %{context: %{current_user: current_user}} ->
        possible_statuses = ApiGateway.Models.Account.User.get_user_billing_status_options_map()
        active_status = possible_statuses.active

        current_user
        |> case do
          nil ->
            {:ok, false}

          %ApiGateway.Models.Account.User{billing_status: ^active_status} ->
            {:ok, true}

          _ ->
            {:ok, false}
        end
      end)
    end

    @desc "Check workspace subdomain available"
    field :check_workspace_subdomain_available, non_null(:boolean) do
      arg(:data, non_null(:check_workspace_subdomain_available_input))

      resolve(&Resolvers.Workspace.check_workspace_subdomain_available/3)
    end

    @desc "Check workspace exists"
    field :check_workspace_exists_by_subdomain, non_null(:boolean) do
      arg(:data, non_null(:check_workspace_exists_by_subdomain_input))

      resolve(&Resolvers.Workspace.check_workspace_exists_by_subdomain/3)
    end

    @desc "Find current logged in user"
    field :current_user, :user do
      resolve(fn _, _, %{context: %{current_user: user}} -> {:ok, user} end)
    end

    @desc "Find a user's workspaces based on given email address and email token"
    field :find_my_workspaces, non_null_list(:workspace) do
      arg(:data, non_null(:find_my_workspaces_input))

      resolve(&Resolvers.FindMyWorkspaces.find_my_workspaces/3)
    end

    @desc "Check whether a user can enter a chat based on provided data"
    field :check_user_can_enter_media_chat, non_null(:boolean) do
      arg(:data, non_null(:check_user_can_enter_media_chat_input))

      resolve(&Resolvers.MediaChat.check_user_can_enter_media_chat/3)
    end

    @desc "Get requested media chat's information"
    field :get_media_chat_info, non_null(:get_media_chat_info_payload) do
      arg(:data, non_null(:get_media_chat_info_input))

      resolve(&Resolvers.MediaChat.get_media_chat_info/3)
    end

    @desc "Check socket token valid"
    field :check_socket_token_valid, non_null(:boolean) do
      arg(:data, non_null(:check_socket_token_valid_input))

      resolve(&Resolvers.Session.verify_token/3)
    end
  end
end
