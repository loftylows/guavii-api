defmodule ApiGatewayWeb.Gql.Schema.MutationType do
  use Absinthe.Schema.Notation
  # import ApiGatewayWeb.Gql.Schema.ScalarHelperFuncs, only: [non_null_list: 1]
  alias ApiGatewayWeb.Gql.Resolvers

  object :root_mutations do
    @desc "Create a workspace using provided data"
    field :create_workspace, :workspace do
      arg(:data, non_null(:workspace_create_input))

      resolve(&Resolvers.Workspace.create_workspace/3)
    end

    @desc "Update a workspace using provided data"
    field :update_workspace, :workspace do
      arg(:data, non_null(:workspace_update_input))
      arg(:where, non_null(:workspace_where_unique_input))

      resolve(&Resolvers.Workspace.update_workspace/3)
    end

    @desc "Delete a workspace"
    field :delete_workspace, :workspace do
      arg(:where, non_null(:workspace_where_unique_input))

      resolve(&Resolvers.Workspace.delete_workspace/3)
    end

    """
    @desc "Create a user using provided data"
    field :create_user, :user do
      arg(:data, non_null(:user_create_input))

      resolve(&Resolvers.User.create_user/3)
    end
    """

    @desc "Update a user using provided data"
    field :update_user, :user do
      arg(:data, non_null(:user_update_input))
      arg(:where, non_null(:user_where_unique_input))

      resolve(&Resolvers.User.update_user/3)
    end

    @desc "Delete a user"
    field :delete_user, :user do
      arg(:where, non_null(:user_where_unique_input))

      resolve(&Resolvers.User.delete_user/3)
    end

    @desc "Create a team using provided data"
    field :create_team, :team do
      arg(:data, non_null(:team_create_input))

      resolve(&Resolvers.Team.create_team/3)
    end

    @desc "Update a team using provided data"
    field :update_team, :team do
      arg(:data, non_null(:team_update_input))
      arg(:where, non_null(:team_where_unique_input))

      resolve(&Resolvers.Team.update_team/3)
    end

    @desc "Delete a team"
    field :delete_team, :team do
      arg(:where, non_null(:team_where_unique_input))

      resolve(&Resolvers.Team.delete_team/3)
    end

    @desc "Create a team using provided data"
    field :create_project, :project do
      arg(:data, non_null(:project_create_input))

      resolve(&Resolvers.Project.create_project/3)
    end

    @desc "Update a team using provided data"
    field :update_project, :project do
      arg(:data, non_null(:project_update_input))
      arg(:where, non_null(:project_where_unique_input))

      resolve(&Resolvers.Project.update_project/3)
    end

    @desc "Delete a team"
    field :delete_project, :project do
      arg(:where, non_null(:project_where_unique_input))

      resolve(&Resolvers.Project.delete_project/3)
    end

    ####################
    # Other mutations #
    ####################
  end
end
