defmodule ApiGatewayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api_gateway
  use Absinthe.Phoenix.Endpoint

  socket "/socket", ApiGatewayWeb.Channels.UserSocket,
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

  # The session will be stored in redis and the cookie will be signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :redis,
    key: "_api_gateway_key",
    # TODO: CHange this and read it from env variables
    signing_salt: "cSLtGnQqy",
    http_only: true,
    # 7 days
    max_age: 604_800

  plug ApiGatewayWeb.Plug.CurrentSubdomain

  plug ApiGatewayWeb.Plug.CurrentUser

  plug ApiGatewayWeb.Router
end
