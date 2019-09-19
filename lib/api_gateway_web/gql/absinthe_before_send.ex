defmodule ApiGatewayWeb.Gql.AbsintheBeforeSend do
  import Plug.Conn

  def absinthe_before_send(conn, %Absinthe.Blueprint{} = blueprint) do
    conn
    |> maybe_login(blueprint)
    |> maybe_logout(blueprint)
  end

  def absinthe_before_send(conn, _) do
    conn
  end

  defp maybe_login(conn, %Absinthe.Blueprint{} = blueprint) do
    if login_info = blueprint.execution.context[:login_info] do
      ApiGateway.Models.Account.User.set_last_login_now(login_info[:user_id])

      conn
      |> put_session(:user_id, login_info[:user_id])
    else
      conn
    end
  end

  defp maybe_logout(conn, %Absinthe.Blueprint{} = blueprint) do
    if blueprint.execution.context[:logout] do
      conn
      |> configure_session(drop: true)
    else
      conn
    end
  end
end
