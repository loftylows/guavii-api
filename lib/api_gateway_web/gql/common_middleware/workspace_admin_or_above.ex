defmodule ApiGatewayWeb.Gql.CommonMiddleware.IsWorkspaceAdminOrAbove do
  @behaviour Absinthe.Middleware

  alias ApiGateway.Models.Workspace

  def call(resolution, _config) do
    roles = Workspace.get_workspace_roles_map()
    owner_role = roles.owner
    admin_role = roles.admin

    case resolution.context do
      %{current_user: %{workspace_role: ^owner_role}} ->
        resolution

      %{current_user: %{workspace_role: ^admin_role}} ->
        resolution

      _ ->
        Absinthe.Resolution.put_result(
          resolution,
          ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
        )
    end
  end
end
