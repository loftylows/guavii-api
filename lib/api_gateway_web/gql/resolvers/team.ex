defmodule ApiGatewayWeb.Gql.Resolvers.Team do
  def get_team(_, %{where: %{id: team_id}}, _) do
    {:ok, ApiGateway.Models.Team.get_team(team_id)}
  end

  def get_teams(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.Team.get_teams(filters)}
  end

  def get_teams(_, _, _) do
    {:ok, ApiGateway.Models.Team.get_teams()}
  end
end
