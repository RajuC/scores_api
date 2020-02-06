defmodule ScoresApiWeb.GameController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Games
  alias ScoresApi.Games.Game

  action_fallback ScoresApiWeb.FallbackController

  def index(conn, _params) do
    games = Games.list_games()
    render(conn, "index.json", games: games)
  end


  def all_games_with_scores(conn, _params) do
    games = Games.list_games(1234)
    render(conn, "g_s_index.json", games: games)
  end

  def create(conn, %{"game" => game_params}) do
    with {:ok, %Game{} = game} <- Games.create_game(game_params) do
      game |> ScoresApi.Utils.store_initial_game_scores
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    render(conn, "show.json", game: game)
  end


end
