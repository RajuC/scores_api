defmodule ScoresApiWeb.ScoreControllerTest do
  use ScoresApiWeb.ConnCase

  alias ScoresApi.Scores
  # alias ScoresApi.Scores.Score

  @create_attrs %{
    game_id: 42,
    game_score: [],
    players: %{},
    round: 42
  }

  @invalid_attrs %{game_id: nil, game_score: nil, players: nil, round: nil}

  def fixture(:score) do
    {:ok, score} = Scores.create_score(@create_attrs)
    score
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "create score" do
    test "renders score when data is valid", %{conn: conn} do
      conn = post(conn, Routes.score_path(conn, :create), score: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.score_path(conn, :show, id))

      assert %{
               "id" => id,
               "game_id" => 42,
               "game_score" => [],
               "players" => %{},
               "round" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.score_path(conn, :create), score: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end


  end


  defp create_score(_) do
    score = fixture(:score)
    {:ok, score: score}
  end
end
