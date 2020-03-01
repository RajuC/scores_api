defmodule ScoresApiWeb.GameControllerTest do
  use ScoresApiWeb.ConnCase

  # alias ScoresApi.Games
  # alias ScoresApi.Games.Game
  alias ScoresApi.Users
    # alias ScoresApi.Users.User
  alias ScoresApiWeb.Auth.Guardian

  @create_attrs %{
    high_pts_to_win: true,
    players: ["raj", "somu", "shas"],
    title: "some title"
  }

  @create_user_attrs %{
    email: "email@email.com",
    name: "some name",
    password: "some password",
    password_confirmation: "some password"
  }
  @invalid_attrs %{high_pts_to_win: nil, players: nil, title: nil}




  setup %{conn: conn} do
    #create user and get token
    {:ok, user} = Users.create_user(@create_user_attrs)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    conn =
      conn
        |> bypass_through(PhoenixTestSession.Router, [:api, :jwt_authenticated])
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer " <> token)
    {:ok, conn: conn}
  end


  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert json_response(conn, 200) == []
    end
  end


  describe "list all games with scores" do
    test "list all games with scores", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :all_games_with_scores))
      assert json_response(conn, 200) == []
    end
  end


  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_attrs)
      assert %{"high_pts_to_win"      => high_pts_to_win,
               "id"                   =>  id,
               "players"              => players,
               "title"                => title
              } = json_response(conn, 201)


      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{
               "id"                   => id,
               "high_pts_to_win"      => high_pts_to_win,
               "players"              => players,
               "title"                => title
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end



end
