defmodule ScoresApi.RoundsTest do
  use ScoresApi.DataCase

  alias ScoresApi.Rounds
  alias ScoresApi.Games
  alias ScoresApi.Users

  describe "rounds" do
    alias ScoresApi.Rounds.Round

    @valid_attrs %{score: [%{"name"=> "raj", "score" => 30}, %{"name" => "som", "score" => 25}], players: %{"active" => ["raj", "som"], "inactive" => []}, round_num: 1}
    @update_attrs %{score: [%{"name"=> "raj", "score" => 35}, %{"name" => "som", "score" => 28}], players: %{"active" => ["raj", "som"], "inactive" => []}, round_num: 1}
    @invalid_attrs %{score: nil, players: nil, round_num: nil}

    @valid_game_attrs  %{high_pts_to_win: true, players: ["raj", "somu"], title: "some title"}
    @create_user_attrs %{email: "email@email.com", name: "some name", password: "some password", password_confirmation: "some password"}


    def round_fixture(game) do
      {:ok, round}  = Rounds.create_round(game, @valid_attrs)
      round
    end

    test "list_rounds/0 returns all rounds" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      [roundd] = Rounds.list_rounds()
      assert  [roundd |> Map.put(:game, game)]== [round]
    end

    test "get_round!/1 returns the round with given id" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      assert round == Rounds.get_round!(round.id) |> Map.put(:game, game)
    end

    test "create_round/1 with valid data creates a round" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      assert {:ok, %Round{} = round} = Rounds.create_round(game, @valid_attrs)
      assert round.score == [%{"name" => "raj", "score" => 30}, %{"name" => "som", "score" => 25}]
      assert round.players == %{"active" => ["raj", "som"], "inactive" => []}
      assert round.round_num == 1
    end

    test "create_round/1 with invalid data returns error changeset" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      assert {:error, %Ecto.Changeset{}} = Rounds.create_round(game, @invalid_attrs)
    end

    test "update_round/2 with valid data updates the round" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      assert {:ok, %Round{} = round} = Rounds.update_round(game, round, @update_attrs)
      assert round.score == [%{"name" => "raj", "score" => 35}, %{"name" => "som", "score" => 28}]
      assert round.players == %{"active" => ["raj", "som"], "inactive" => []}
      assert round.round_num == 1
    end

    test "update_round/2 with invalid data returns error changeset" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      assert {:error, %Ecto.Changeset{}} = Rounds.update_round(game, round, @invalid_attrs)
      assert round == Rounds.get_round!(round.id) |> Map.put(:game, game)
    end

    test "delete_round/1 deletes the round" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      assert {:ok, %Round{}} = Rounds.delete_round(round)
      assert_raise Ecto.NoResultsError, fn -> Rounds.get_round!(round.id) end
    end

    test "change_round/1 returns a round changeset" do
      {:ok, user}   = Users.create_user(@create_user_attrs)
      {:ok, game}   = Games.create_game(user, @valid_game_attrs)
      round = round_fixture(game)
      assert %Ecto.Changeset{} = Rounds.change_round(round)
    end
  end
end
