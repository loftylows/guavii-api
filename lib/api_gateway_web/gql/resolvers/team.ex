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

  def create_team(_, %{data: data}, _) do
    case ApiGateway.Models.Team.create_team(data) do
      {:ok, team} ->
        {:ok, team}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset(
          "Team input error",
          errors
        )

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Team input error")
    end
  end

  def update_team(_, %{data: data, where: %{id: id}}, _) do
    case ApiGateway.Models.Team.update_team(%{id: id, data: data}) do
      {:ok, team} ->
        {:ok, team}

      {:error, %{errors: errors}} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error_from_changeset("Team input error", errors)

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Team not found")

      {:error, _} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Team input error")
    end
  end

  def delete_team(_, %{where: %{id: id}}, _) do
    case ApiGateway.Models.Team.delete_team(id) do
      {:ok, team} ->
        {:ok, team}

      {:error, "Not found"} ->
        ApiGatewayWeb.Gql.Utils.Errors.user_input_error("Team not found")
    end
  end

  ####################
  # Relation resolvers #
  ####################
end
