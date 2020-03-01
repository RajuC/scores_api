defmodule ScoresApiWeb.GameController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Games
  alias ScoresApi.GamesScores
  alias ScoresApi.Games.Game

  action_fallback ScoresApiWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = Games.list_games(user)
    render(conn, "index.json", games: games)
  end

  def all_games_with_scores(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = GamesScores.list_games_scores(user)
    render(conn, "g_s_index.json", games: games)
  end


  def create(conn, %{"game" => game_params}) do
    user = Guardian.Plug.current_resource(conn)
    with {:ok, %Game{} = game} <- Games.create_game(user, game_params) do
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

  # def update(conn, %{"id" => id, "game" => game_params}) do
  #   game = Games.get_game!(id)
  #
  #   with {:ok, %Game{} = game} <- Games.update_game(game, game_params) do
  #     render(conn, "show.json", game: game)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   game = Games.get_game!(id)
  #
  #   with {:ok, %Game{}} <- Games.delete_game(game) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
