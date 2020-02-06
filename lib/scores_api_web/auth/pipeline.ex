defmodule ScoresApiWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :ScoresApiWeb,
  module: ScoresApiWeb.Guardian,
  error_handler: ScoresApiWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
