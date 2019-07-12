defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward("/api", Absinthe.Plug, schema: ApiGatewayWeb.Schema.Schema)

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: ApiGatewayWeb.Schema.Schema
  end
end
