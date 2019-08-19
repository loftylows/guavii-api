defmodule ApiGatewayWeb.Gql.Schema.QueryType do
  use Absinthe.Schema.Notation
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  alias ApiGatewayWeb.Gql.Resolvers

  object :root_queries do
    @desc "Get a workspace using criteria"
    field :workspace, :workspace do
      arg(:where, non_null(:workspace_where_unique_input))

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

    @desc "Get all users, optionally filtering"
    field :users, non_null_list(:user) do
      arg(:where, :user_where_input)

      middleware(ApiGatewayWeb.Gql.CommonMiddleware.Authenticated)
      resolve(&Resolvers.User.get_users/3)
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

      # TODO: implement resolver
      # resolve(&Resolvers.KanbanCard.get_kanban_card/3)
    end

    @desc "Check workspace subdomain available"
    field :check_workspace_subdomain_available, non_null(:boolean) do
      arg(:data, non_null(:check_workspace_subdomain_available_input))

      resolve(&Resolvers.Workspace.check_workspace_subdomain_available/3)
    end

    @desc """
    Check whether a provided app invitation token is valid.
    May be invalid if already used, past the expiration date or not genuine.
    """
    field :check_user_invite_token_valid, non_null(:boolean) do
      arg(:data, non_null(:check_user_invite_token_valid_input))

      # TODO: implement resolver
      # resolve(&Resolvers.KanbanCard.get_kanban_card/3)
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
  end
end
