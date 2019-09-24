defmodule ApiGatewayWeb.Gql.CommonMiddleware.IsWorkspaceOwner do
  @behaviour Absinthe.Middleware

  alias ApiGateway.Models.Workspace

  def call(resolution, _config) do
    roles = Workspace.get_workspace_roles_map()
    owner_role = roles.owner

    case resolution.context do
      %{current_user: %{workspace_role: ^owner_role}} ->
        resolution

      _ ->
        Absinthe.Resolution.put_result(
          resolution,
          ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
        )
    end
  end
end
