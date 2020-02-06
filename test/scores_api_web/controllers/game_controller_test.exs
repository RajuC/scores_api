defmodule ScoresApiWeb.GameControllerTest do
  use ScoresApiWeb.ConnCase

  alias ScoresApi.Games
  alias ScoresApi.Games.Game

  @create_attrs %{
    high_pts_to_win: true,
    players: [],
    title: "some title",
    user_id: 42
  }

  @invalid_attrs %{high_pts_to_win: nil, players: nil, title: nil, user_id: nil}

  def fixture(:game) do
    {:ok, game} = Games.create_game(@create_attrs)
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end


  describe "list all games with scores" do
    test "list all games with scores", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :all_games_with_scores))
      assert json_response(conn, 200)["data"] == []
    end
  end



  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{
               "id" => id,
               "high_pts_to_win" => true,
               "players" => [],
               "title" => "some title",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end


  defp create_game(_) do
    game = fixture(:game)
    {:ok, game: game}
  end
end
