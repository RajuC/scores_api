# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :scores_api,
  ecto_repos: [ScoresApi.Repo]

# Configures the endpoint
config :scores_api, ScoresApiWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  secret_key_base: "prZLtQfd9X2tClaXky+D1Fl3kH0zqqacCFpvpbPkIP9ddl0d698DbbwfRUk1CMCi",
  render_errors: [view: ScoresApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ScoresApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"



# Guardian config
config :scores_api, ScoresApiWeb.Auth.Guardian,
      issuer: "scores_api",
      ttl: { 2, :days },
      secret_key: "sjxhzlLxh+0RKH7Sk+wgkWBlqABMQpa7qtO5ahO/IcqFzCccQAR5DYq+zNJe40yq"
