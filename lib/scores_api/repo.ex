defmodule ScoresApi.Repo do
  use Ecto.Repo,
    otp_app: :scores_api,
    adapter: Ecto.Adapters.Postgres
end
