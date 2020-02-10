defmodule ScoresApiWeb.ScoreControllerTest do
  use ScoresApiWeb.ConnCase

  alias ScoresApi.Scores
  # alias ScoresApi.Scores.Score
  alias ScoresApi.Users
    # alias ScoresApi.Users.User
  alias ScoresApiWeb.Auth.Guardian
    alias ScoresApi.Games

  @create_attrs %{
    game_score: [],
    players: %{},
    round: 42
  }

  @create_user_attrs %{
    email: "email@email.com",
    name: "some name",
    password: "some password",
    password_confirmation: "some password"
  }

  @create_game_attrs %{
    high_pts_to_win: true,
    players: ["raj", "somu", "shas"],
    title: "some title"
  }

  @invalid_attrs %{game_id: nil, game_score: nil, players: nil, round: nil}

  def fixture(:score) do
    {:ok, score} = Scores.create_score(@create_attrs)
    score
  end


  setup %{conn: conn} do
    #create user and get token
    {:ok, user} = Users.create_user(@create_user_attrs)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    # create game
    mod_game_params = Map.put(@create_game_attrs, :user_id, user.id)
    {:ok, game} = Games.create_game(mod_game_params)
    # add authorization header to request
    conn = conn |> put_req_header("authorization", "Bearer #{token}")
                # |> put_req_header("user_id", Enum.to_list(user.id))
                |> put_req_header("game_id", Kernel.to_string(game.id))
      # pass the connection and the user to the test
    {:ok, conn: conn}
  end


  describe "create score" do
    test "renders score when data is valid", %{conn: conn} do
      [game_id] = conn |> get_req_header("game_id")
      mod_score_params = Map.put(@create_attrs, :game_id, String.to_integer(game_id))
      conn = post(conn, Routes.score_path(conn, :create), score: mod_score_params)
      assert %{"id" => id, "game_id" => game_id, "game_score" => game_score, "players" => players, "round" => round} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.score_path(conn, :show, id))

      assert %{
               "id" => id,
               "game_id" => game_id,
               "game_score" => game_score,
               "players" => players,
               "round" => round
             } = json_response(conn, 200)["data"]
    end


    test "renders errors when game_id is invalid/not_found", %{conn: conn} do
      conn = post(conn, Routes.score_path(conn, :create), score: @invalid_attrs)
      assert text_response(conn, 404) == "Game Id not found for User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      [game_id] = conn |> get_req_header("game_id")
      invalid_params_with_game_id = @invalid_attrs |> Map.put(:game_id, String.to_integer(game_id))
      conn = post(conn, Routes.score_path(conn, :create), score: invalid_params_with_game_id)
      assert json_response(conn, 422)["errors"] != %{}
    end


  end


  # defp create_score(_) do
  #   score = fixture(:score)
  #   {:ok, score: score}
  # end
end
