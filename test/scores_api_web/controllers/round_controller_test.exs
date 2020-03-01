defmodule ScoresApiWeb.RoundControllerTest do
  use ScoresApiWeb.ConnCase

  alias ScoresApi.Users
  alias ScoresApi.Rounds
  # alias ScoresApi.Rounds.Round
  alias ScoresApiWeb.Auth.Guardian

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

  @create_attrs %{
      game_score: [],
      players: %{},
      round_num: 1
      }

    # @update_attrs %{
    #     game_score: [],
    #     players: %{active: ["somu", "raj", "shashi", "sandeep", "nikhil"], inactive: [] },
    #     round_num: 1
    #     }

  @invalid_attrs %{game_id: nil, game_score: nil, players: nil, round_num: nil}

  def fixture(:round) do
    {:ok, round} = Rounds.create_round(@create_attrs)
    round
  end

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


  # describe "index" do
  #   test "lists all rounds", %{conn: conn} do
  #     conn = get(conn, Routes.round_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "create round" do
    test "renders round when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_game_attrs)
      assert %{"id" => game_id} = json_response(conn, 201)

      conn = post(conn, Routes.round_path(conn, :create), %{game_id: game_id, round: @create_attrs})
      assert %{"game_id" => game_id, "id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.round_path(conn, :show, id))

      assert %{
               "id"         => id,
               "game_id"    => game_id,
               "game_score" => [],
               "players"    => %{},
               "round_num"  => 1
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_game_attrs)
      assert %{"id" => game_id } = json_response(conn, 201)
      
      conn = post(conn, Routes.round_path(conn, :create), %{game_id: game_id, round: @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "update round" do
  #   setup [:create_round]
  #
  #   test "renders round when data is valid", %{conn: conn, round: %Round{id: id} = round} do
  #     conn = put(conn, Routes.round_path(conn, :update, round), round: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]
  #
  #     conn = get(conn, Routes.round_path(conn, :show, id))
  #
  #     assert %{
  #              "id" => id,
  #              "game_id" => 43,
  #              "game_score" => [],
  #              "players" => {},
  #              "round_num" => 43
  #            } = json_response(conn, 200)["data"]
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn, round: round} do
  #     conn = put(conn, Routes.round_path(conn, :update, round), round: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete round" do
  #   setup [:create_round]
  #
  #   test "deletes chosen round", %{conn: conn, round: round} do
  #     conn = delete(conn, Routes.round_path(conn, :delete, round))
  #     assert response(conn, 204)
  #
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.round_path(conn, :show, round))
  #     end
  #   end
  # end
  #
  # defp create_round(_) do
  #   round = fixture(:round)
  #   {:ok, round: round}
  # end
end
