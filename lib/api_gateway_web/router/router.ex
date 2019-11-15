defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router
  import Plug.Conn

  @spec get_user_unique_identifier(conn :: Plug.Conn.t()) :: String.t()
  def get_user_unique_identifier(conn) do
    get_session(conn, :user_id)
    |> case do
      nil ->
        conn.remote_ip |> :inet_parse.ntoa() |> to_string()

      user_id ->
        user_id
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ApiGatewayWeb.Plug.GqlContext

    plug Hammer.Plug,
      # Limit requests to 500 per minute from a single user or ip address if user is not logged in
      rate_limit: {"api", 60_000, 500},
      by: {:conn, &__MODULE__.get_user_unique_identifier/1},
      when_nil: :raise
  end

  scope "/" do
    pipe_through :api

    forward("/gql", Absinthe.Plug,
      schema: ApiGatewayWeb.Gql.Schema.Schema,
      before_send: {ApiGatewayWeb.Gql.AbsintheBeforeSend, :absinthe_before_send},
      analyze_complexity: true,
      max_complexity: 1000
    )

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: ApiGatewayWeb.Gql.Schema.Schema,
      socket: ApiGatewayWeb.Channels.UserSocket,
      before_send: {ApiGatewayWeb.Gql.AbsintheBeforeSend, :absinthe_before_send},
      analyze_complexity: true,
      max_complexity: 1000
  end
end
