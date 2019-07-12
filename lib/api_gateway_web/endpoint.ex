defmodule ApiGatewayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api_gateway

  socket "/socket", ApiGatewayWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :api_gateway,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_api_gateway_key",
    signing_salt: "cSLtGnQqy"

  # plug Absinthe.Plug,
  # schema: ApiGateway.Gql.Schema

  plug ApiGatewayWeb.Router
end
