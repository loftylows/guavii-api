use Mix.Config

# Configure your database
config :api_gateway, ApiGateway.Repo,
  username: "postgres",
  password: "postgres",
  database: "api_gateway_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :api_gateway, ApiGatewayWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :bamboo, :json_library, Jason

config :api_gateway,
  environment: :dev,
  transactional_email_api_token: System.get_env("TRANSACTIONAL_EMAIL_API_TOKEN"),
  password_hash_pepper: System.get_env("PASSWORD_HASH_PEPPER"),
  email_invite_token_hash_pepper: System.get_env("EMAIL_INVITE_TOKEN_HASH_PEPPER"),
  session_secret: System.get_env("SESSION_SECRET"),
  jwt_private_key: System.get_env("JWT_PRIVATE_KEY"),
  jwt_public_key: System.get_env("JWT_PUBLIC_KEY"),
  jwt_issuer: System.get_env("JWT_ISSUER"),
  jwt_audience: System.get_env("JWT_AUDIENCE"),
  website_host: System.get_env("WEBSITE_HOST"),
  website_url: System.get_env("WEBSITE_URL")

config :api_gateway, ApiGateway.Mailer,
  adapter: Bamboo.PostmarkAdapter,
  api_key: System.get_env("TRANSACTIONAL_EMAIL_API_TOKEN")

# Exredis is used by the 'redbird' library
config :exredis,
  url: System.get_env("REDIS_URL")

config :redix_pool,
  redis_url: System.get_env("REDIS_URL"),
  pool_size: 10,
  pool_max_overflow: 10
