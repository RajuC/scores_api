defmodule ScoresApiWeb.GameController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Games
  alias ScoresApi.Games.Game

  action_fallback ScoresApiWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = Games.list_games(user.id)
    render(conn, "index.json", games: games)
  end


  def all_games_with_scores(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = Games.list_games_scores(user.id)
    render(conn, "g_s_index.json", games: games)
  end

  def create(conn, %{"game" => game_params}) do
    user = Guardian.Plug.current_resource(conn)
    mod_game_params = Map.put(game_params, "user_id", user.id)
    with {:ok, %Game{} = game} <- Games.create_game(mod_game_params) do
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
