defmodule ScoresApiWeb.ScoreController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Scores
  alias ScoresApi.Scores.Score

  action_fallback ScoresApiWeb.FallbackController


  def create(conn, %{"score" => score_params}) do
    user = Guardian.Plug.current_resource(conn)
    case ScoresApi.Utils.validate_game_score(user.id, score_params) do
      {:error, error} ->
        {:error, error}
      :ok ->
        with {:ok, %Score{} = score} <- Scores.create_score(score_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.score_path(conn, :show, score))
          |> render("show.json", score: score)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    score = Scores.get_score!(id)
    render(conn, "show.json", score: score)
  end
end
