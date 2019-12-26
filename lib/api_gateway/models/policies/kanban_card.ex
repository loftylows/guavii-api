defmodule ApiGateway.Models.Policies.KanbanCard do
  alias ApiGateway.Models.Account.User
  alias ApiGateway.Models.KanbanCard
  alias ApiGateway.Models.Project

  @spec can_create?(
          subject :: User.t(),
          project_id :: Ecto.UUID.t(),
          action :: :create | :read | :update | :delete
        ) ::
          boolean
  def can_create?(user, project_id, :create) do
    case Project.get_project(project_id) do
      nil ->
        false
      project ->
        user.workspace_id == project.workspace_id
    end
  end
end
