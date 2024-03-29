# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :api_gateway,
  ecto_repos: [ApiGateway.Repo],
  generators: [binary_id: true]

# Configures the repo
config :api_gateway, ApiGateway.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :api_gateway, ApiGatewayWeb.Endpoint,
  url: [host: System.get_env("WEBSITE_HOST")],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: ApiGatewayWeb.ErrorView, accepts: ~w(json)],
  # TODO: change this to the redis adapter
  pubsub: [name: ApiGateway.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :api_gateway, ApiGateway.Scheduler,
  jobs: [
    # Runs every midnight:
    {"@daily",
     {ApiGateway.Models.ArchivedWorkspaceSubdomain, :delete_out_of_date_archived_domains, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
