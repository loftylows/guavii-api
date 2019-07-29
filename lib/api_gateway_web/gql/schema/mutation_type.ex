defmodule ApiGatewayWeb.Gql.Schema.MutationType do
  use Absinthe.Schema.Notation
  alias ApiGatewayWeb.Gql.Resolvers

  object :root_mutations do
    @desc "Create a workspace using provided data"
    field :create_workspace, non_null(:workspace) do
      arg(:data, non_null(:workspace_create_input))

      resolve(&Resolvers.Workspace.create_workspace/3)
    end

    @desc "Update a workspace using provided data"
    field :update_workspace, non_null(:workspace) do
      arg(:data, non_null(:workspace_update_input))
      arg(:where, non_null(:workspace_where_unique_input))

      resolve(&Resolvers.Workspace.update_workspace/3)
    end

    @desc "Delete a workspace"
    field :delete_workspace, non_null(:workspace) do
      arg(:where, non_null(:workspace_where_unique_input))

      resolve(&Resolvers.Workspace.delete_workspace/3)
    end

    """
    @desc "Create a user using provided data"
    field :create_user, non_null(:user) do
      arg(:data, non_null(:user_create_input))

      resolve(&Resolvers.User.create_user/3)
    end
    """

    @desc "Update a user using provided data"
    field :update_user, non_null(:user) do
      arg(:data, non_null(:user_update_input))
      arg(:where, non_null(:user_where_unique_input))

      resolve(&Resolvers.User.update_user/3)
    end

    @desc "Delete a user"
    field :delete_user, non_null(:user) do
      arg(:where, non_null(:user_where_unique_input))

      resolve(&Resolvers.User.delete_user/3)
    end

    @desc "Create a team using provided data"
    field :create_team, non_null(:team) do
      arg(:data, non_null(:team_create_input))

      resolve(&Resolvers.Team.create_team/3)
    end

    @desc "Update a team using provided data"
    field :update_team, non_null(:team) do
      arg(:data, non_null(:team_update_input))
      arg(:where, non_null(:team_where_unique_input))

      resolve(&Resolvers.Team.update_team/3)
    end

    @desc "Delete a team"
    field :delete_team, non_null(:team) do
      arg(:where, non_null(:team_where_unique_input))

      resolve(&Resolvers.Team.delete_team/3)
    end

    @desc "Create a project using provided data"
    field :create_project, non_null(:project) do
      arg(:data, non_null(:project_create_input))

      resolve(&Resolvers.Project.create_project/3)
    end

    @desc "Update a project using provided data"
    field :update_project, non_null(:project) do
      arg(:data, non_null(:project_update_input))
      arg(:where, non_null(:project_where_unique_input))

      resolve(&Resolvers.Project.update_project/3)
    end

    @desc "Delete a project"
    field :delete_project, non_null(:project) do
      arg(:where, non_null(:project_where_unique_input))

      resolve(&Resolvers.Project.delete_project/3)
    end

    @desc "Create a document using provided data"
    field :create_document, non_null(:document) do
      arg(:data, non_null(:document_create_input))

      resolve(&Resolvers.Document.create_document/3)
    end

    @desc "Update a document using provided data"
    field :update_document, non_null(:document) do
      arg(:data, non_null(:document_update_input))
      arg(:where, non_null(:document_where_unique_input))

      resolve(&Resolvers.Document.update_document/3)
    end

    @desc "Delete a document"
    field :delete_document, non_null(:document) do
      arg(:where, non_null(:document_where_unique_input))

      resolve(&Resolvers.Document.delete_document/3)
    end

    @desc "Create a project_todo_list using provided data"
    field :create_project_todo_list, non_null(:project_todo_list) do
      arg(:data, non_null(:project_todo_list_create_input))

      resolve(&Resolvers.ProjectTodoList.create_project_todo_list/3)
    end

    @desc "Update a project_todo_list using provided data"
    field :update_project_todo_list, non_null(:project_todo_list) do
      arg(:data, non_null(:project_todo_list_update_input))
      arg(:where, non_null(:project_todo_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.ProjectTodoList.update_project_todo_list/3)
    end

    @desc "Delete a project_todo_list"
    field :delete_project_todo_list, non_null(:project_todo_list) do
      arg(:where, non_null(:project_todo_list_where_unique_input))

      resolve(&Resolvers.ProjectTodoList.delete_project_todo_list/3)
    end

    @desc "Create a project_todo using provided data"
    field :create_project_todo, non_null(:project_todo) do
      arg(:data, non_null(:project_todo_create_input))

      resolve(&Resolvers.ProjectTodo.create_project_todo/3)
    end

    @desc "Update a project_todo using provided data"
    field :update_project_todo, non_null(:project_todo) do
      arg(:data, non_null(:project_todo_update_input))
      arg(:where, non_null(:project_todo_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.ProjectTodo.update_project_todo/3)
    end

    @desc "Delete a project_todo"
    field :delete_project_todo, non_null(:project_todo) do
      arg(:where, non_null(:project_todo_where_unique_input))

      resolve(&Resolvers.ProjectTodo.delete_project_todo/3)
    end

    @desc "Create a sub_list using provided data"
    field :create_sub_list, non_null(:sub_list) do
      arg(:data, non_null(:sub_list_create_input))

      resolve(&Resolvers.SubList.create_sub_list/3)
    end

    @desc "Update a sub_list using provided data"
    field :update_sub_list, non_null(:sub_list) do
      arg(:data, non_null(:sub_list_update_input))
      arg(:where, non_null(:sub_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.SubList.update_sub_list/3)
    end

    @desc "Delete a sub_list"
    field :delete_sub_list, non_null(:sub_list) do
      arg(:where, non_null(:sub_list_where_unique_input))

      resolve(&Resolvers.SubList.delete_sub_list/3)
    end

    @desc "Create a sub_list_item using provided data"
    field :create_sub_list_item, non_null(:sub_list_item) do
      arg(:data, non_null(:sub_list_item_create_input))

      resolve(&Resolvers.SubListItem.create_sub_list_item/3)
    end

    @desc "Update a sub_list_item using provided data"
    field :update_sub_list_item, non_null(:sub_list_item) do
      arg(:data, non_null(:sub_list_item_update_input))
      arg(:where, non_null(:sub_list_item_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.SubListItem.update_sub_list_item/3)
    end

    @desc "Delete a sub_list_item"
    field :delete_sub_list_item, non_null(:sub_list_item) do
      arg(:where, non_null(:sub_list_item_where_unique_input))

      resolve(&Resolvers.SubListItem.delete_sub_list_item/3)
    end

    @desc "Create a sub_list_item_comment using provided data"
    field :create_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:data, non_null(:sub_list_item_comment_create_input))

      resolve(&Resolvers.SubListItemComment.create_sub_list_item_comment/3)
    end

    @desc "Update a sub_list_item_comment using provided data"
    field :update_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:data, non_null(:sub_list_item_comment_update_input))
      arg(:where, non_null(:sub_list_item_comment_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.SubListItemComment.update_sub_list_item_comment/3)
    end

    @desc "Delete a sub_list_item_comment"
    field :delete_sub_list_item_comment, non_null(:sub_list_item_comment) do
      arg(:where, non_null(:sub_list_item_comment_where_unique_input))

      resolve(&Resolvers.SubListItemComment.delete_sub_list_item_comment/3)
    end

    @desc "Create a kanban_label using provided data"
    field :create_kanban_label, non_null(:kanban_label) do
      arg(:data, non_null(:kanban_label_create_input))

      resolve(&Resolvers.KanbanLabel.create_kanban_label/3)
    end

    @desc "Update a kanban_label using provided data"
    field :update_kanban_label, non_null(:kanban_label) do
      arg(:data, non_null(:kanban_label_update_input))
      arg(:where, non_null(:kanban_label_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanLabel.update_kanban_label/3)
    end

    @desc "Delete a kanban_label"
    field :delete_kanban_label, non_null(:kanban_label) do
      arg(:where, non_null(:kanban_label_where_unique_input))

      resolve(&Resolvers.KanbanLabel.delete_kanban_label/3)
    end

    @desc "Create a kanban_lane using provided data"
    field :create_kanban_lane, non_null(:kanban_lane) do
      arg(:data, non_null(:kanban_lane_create_input))

      resolve(&Resolvers.KanbanLane.create_kanban_lane/3)
    end

    @desc "Update a kanban_lane using provided data"
    field :update_kanban_lane, non_null(:kanban_lane) do
      arg(:data, non_null(:kanban_lane_update_input))
      arg(:where, non_null(:kanban_lane_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanLane.update_kanban_lane/3)
    end

    @desc "Delete a kanban_lane"
    field :delete_kanban_lane, non_null(:kanban_lane) do
      arg(:where, non_null(:kanban_lane_where_unique_input))

      resolve(&Resolvers.KanbanLane.delete_kanban_lane/3)
    end

    @desc "Create a kanban_card using provided data"
    field :create_kanban_card, non_null(:kanban_card) do
      arg(:data, non_null(:kanban_card_create_input))

      resolve(&Resolvers.KanbanCard.create_kanban_card/3)
    end

    @desc "Update a kanban_card using provided data"
    field :update_kanban_card, non_null(:kanban_card) do
      arg(:data, non_null(:kanban_card_update_input))
      arg(:where, non_null(:kanban_card_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanCard.update_kanban_card/3)
    end

    @desc "Delete a kanban_card"
    field :delete_kanban_card, non_null(:kanban_card) do
      arg(:where, non_null(:kanban_card_where_unique_input))

      resolve(&Resolvers.KanbanCard.delete_kanban_card/3)
    end

    @desc "Create a kanban_card_comment using provided data"
    field :create_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:data, non_null(:kanban_card_comment_create_input))

      resolve(&Resolvers.KanbanCardComment.create_kanban_card_comment/3)
    end

    @desc "Update a kanban_card_comment using provided data"
    field :update_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:data, non_null(:kanban_card_comment_update_input))
      arg(:where, non_null(:kanban_card_comment_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanCardComment.update_kanban_card_comment/3)
    end

    @desc "Delete a kanban_card_comment"
    field :delete_kanban_card_comment, non_null(:kanban_card_comment) do
      arg(:where, non_null(:kanban_card_comment_where_unique_input))

      resolve(&Resolvers.KanbanCardComment.delete_kanban_card_comment/3)
    end

    @desc "Create a kanban_card_todo_list using provided data"
    field :create_kanban_card_todo_list, non_null(:kanban_card_todo_list) do
      arg(:data, non_null(:kanban_card_todo_list_create_input))

      resolve(&Resolvers.KanbanCardTodoList.create_kanban_card_todo_list/3)
    end

    @desc "Update a kanban_card_todo_list using provided data"
    field :update_kanban_card_todo_list, non_null(:kanban_card_todo_list) do
      arg(:data, non_null(:kanban_card_todo_list_update_input))
      arg(:where, non_null(:kanban_card_todo_list_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanCardTodoList.update_kanban_card_todo_list/3)
    end

    @desc "Delete a kanban_card_todo_list"
    field :delete_kanban_card_todo_list, non_null(:kanban_card_todo_list) do
      arg(:where, non_null(:kanban_card_todo_list_where_unique_input))

      resolve(&Resolvers.KanbanCardTodoList.delete_kanban_card_todo_list/3)
    end

    @desc "Create a kanban_card_todo using provided data"
    field :create_kanban_card_todo, non_null(:kanban_card_todo) do
      arg(:data, non_null(:kanban_card_todo_create_input))

      resolve(&Resolvers.KanbanCardTodo.create_kanban_card_todo/3)
    end

    @desc "Update a kanban_card_todo using provided data"
    field :update_kanban_card_todo, non_null(:kanban_card_todo) do
      arg(:data, non_null(:kanban_card_todo_update_input))
      arg(:where, non_null(:kanban_card_todo_where_unique_input))
      arg(:list_item_position, :list_item_position_input)

      resolve(&Resolvers.KanbanCardTodo.update_kanban_card_todo/3)
    end

    @desc "Delete a kanban_card_todo"
    field :delete_kanban_card_todo, non_null(:kanban_card_todo) do
      arg(:where, non_null(:kanban_card_todo_where_unique_input))

      resolve(&Resolvers.KanbanCardTodo.delete_kanban_card_todo/3)
    end

    ####################
    # Other mutations #
    ####################
  end
end
