defmodule ApiGatewayWeb.Gql.Resolvers.User do
  def get_user(_, %{where: %{id: user_id}}, _) do
    {:ok, ApiGateway.Models.User.get_user(user_id)}
  end

  def get_users(_, %{where: filters}, _) do
    {:ok, ApiGateway.Models.User.get_users(filters)}
  end

  def get_users(_, _, _) do
    {:ok, ApiGateway.Models.User.get_users()}
  end
end
