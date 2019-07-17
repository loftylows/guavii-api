defmodule ApiGatewayWeb.Gql.Schema.QueryType do
  use Absinthe.Schema.Notation
  import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  alias ApiGatewayWeb.Gql.Resolvers

  object :root_queries do
    @desc "Get a workspace using criteria"
    field :workspace, :workspace do
      arg(:where, non_null(:workspace_where_unique_input))

      resolve(&Resolvers.Workspace.get_workspace/3)
    end

    @desc "Get a user using criteria"
    field :user, :user do
      arg(:where, non_null(:user_where_unique_input))

      resolve(&Resolvers.User.get_user/3)
    end

    @desc "Get all users, optionally filtering"
    field :users, non_null_list(:user) do
      arg(:where, :user_where_input)

      resolve(&Resolvers.User.get_users/3)
    end

    @desc "Get a team using criteria"
    field :team, :team do
      arg(:where, non_null(:team_where_unique_input))

      resolve(&Resolvers.Team.get_team/3)
    end

    @desc "Get all teams, optionally filtering"
    field :teams, non_null_list(:team) do
      arg(:where, :team_where_input)

      resolve(&Resolvers.Team.get_teams/3)
    end

    @desc "Get a project using criteria"
    field :project, :project do
      arg(:where, non_null(:project_where_unique_input))

      resolve(&Resolvers.Project.get_project/3)
    end

    @desc "Get a document using criteria"
    field :document, :document do
      arg(:where, non_null(:document_where_unique_input))

      resolve(&Resolvers.Document.get_document/3)
    end

    @desc "Get all documents, optionally filtering"
    field :documents, non_null_list(:document) do
      arg(:where, :document_where_input)

      resolve(&Resolvers.Document.get_documents/3)
    end

    @desc "Get a kanban card using criteria"
    field :kanban_card, :kanban_card do
      arg(:where, non_null(:kanban_card_where_unique_input))

      resolve(&Resolvers.KanbanCard.get_kanban_card/3)
    end
  end
end
