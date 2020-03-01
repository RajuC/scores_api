defmodule ScoresApiWeb.RoundController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Rounds
  alias ScoresApi.Games
  alias ScoresApi.Rounds.Round

  action_fallback ScoresApiWeb.FallbackController

  # def index(conn, _params) do
  #   rounds = Rounds.list_rounds()
  #   render(conn, "index.json", rounds: rounds)
  # end

  def create(conn, %{"game_id" => game_id, "round" => round_params}) do
    game = Games.get_game!(game_id)
    with {:ok, %Round{} = round} <- Rounds.create_round(game, round_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.round_path(conn, :show, round))
      |> render("show.json", round: round)
    end
  end

  def show(conn, %{"id" => id}) do
    round = Rounds.get_round!(id)
    render(conn, "show.json", round: round)
  end

  # def update(conn, %{"id" => id, "round" => round_params}) do
  #   round = Rounds.get_round!(id)
  #
  #   with {:ok, %Round{} = round} <- Rounds.update_round(round, round_params) do
  #     render(conn, "show.json", round: round)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   round = Rounds.get_round!(id)
  #
  #   with {:ok, %Round{}} <- Rounds.delete_round(round) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
