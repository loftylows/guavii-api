defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ApiGatewayWeb.Plug.GqlContext
  end

  scope "/" do
    pipe_through :api

    forward("/api", Absinthe.Plug,
      schema: ApiGatewayWeb.Gql.Schema.Schema,
      before_send: &ApiGatewayWeb.Gql.AbsintheBeforeSend.absinthe_before_send/2
    )

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: ApiGatewayWeb.Gql.Schema.Schema,
      socket: ApiGatewayWeb.Channels.UserSocket
  end
end
