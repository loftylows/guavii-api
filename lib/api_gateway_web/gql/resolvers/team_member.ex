defmodule ApiGatewayWeb.Gql.Resolvers.TeamMember do
  alias ApiGatewayWeb.Gql.Utils.Errors
  alias ApiGateway.Models

  def update_team_member(_, %{data: data, where: %{id: id}}, _) do
    case Models.TeamMember.update_team_member(%{id: id, data: data}) do
      {:ok, team_member} ->
        {:ok, team_member}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("Team member input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("Team member not found")

      {:error, _} ->
        Errors.user_input_error("Team member input error")
    end
  end
end
