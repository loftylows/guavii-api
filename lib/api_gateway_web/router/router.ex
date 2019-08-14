defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ApiGatewayWeb.Plug.GqlContext
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
