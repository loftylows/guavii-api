defmodule ApiGatewayWeb.Gql.Resolvers.Team do
  alias ApiGatewayWeb.Gql.Utils.Errors
  alias ApiGateway.Models

  def get_team(_, %{where: %{id: team_id}}, _) do
    {:ok, Models.Team.get_team(team_id)}
  end

  def get_teams(_, %{where: filters}, _) do
    {:ok, Models.Team.get_teams(filters)}
  end

  def get_teams(_, _, _) do
    {:ok, Models.Team.get_teams()}
  end

  def create_team(_, %{data: _}, %{context: %{current_user: nil}}) do
    ApiGatewayWeb.Gql.Utils.Errors.forbidden_error()
  end

  def create_team(_, %{data: data}, %{context: %{current_user: user}}) do
    case Models.Team.create_team_with_member(data, user) do
      {:ok, team} ->
        {:ok, team}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset(
          "Team input error",
          errors
        )

      {:error, :internal_error} ->
        Errors.internal_error()

      {:error, _} ->
        Errors.user_input_error("Team input error")
    end
  end

  def update_team(_, %{data: data, where: %{id: id}}, _) do
    case Models.Team.update_team(%{id: id, data: data}) do
      {:ok, team} ->
        {:ok, team}

      {:error, %{errors: errors}} ->
        Errors.user_input_error_from_changeset("Team input error", errors)

      {:error, "Not found"} ->
        Errors.user_input_error("Team not found")

      {:error, _} ->
        Errors.user_input_error("Team input error")
    end
  end

  def delete_team(_, %{where: %{id: id}}, _) do
    case Models.Team.delete_team(id) do
      {:ok, team} ->
        {:ok, team}

      {:error, "Not found"} ->
        Errors.user_input_error("Team not found")
    end
  end

  def register_users_with_team(_, _, %{context: %{current_user: nil}}) do
    Errors.forbidden_error()
  end

  def register_users_with_team(_, %{where: %{id: id}, data: data}, %{
        context: %{current_user: current_user}
      }) do
    case Models.Team.add_team_members(%{id: id, data: data}, current_user) do
      {:ok, _payload} = result ->
        result

      {:error, _} ->
        Errors.user_input_error("User input error.")
    end
  end

  def remove_user_from_team(_, %{where: %{id: id}}, _) do
    case Models.Team.remove_user_from_team(id) do
      {:ok, _payload} = result ->
        result

      {:error, error} when is_binary(error) ->
        Errors.user_input_error(error)

      _ ->
        Errors.user_input_error("User input error.")
    end
  end
end
