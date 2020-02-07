defmodule ScoresApi.GamesTest do
  use ScoresApi.DataCase

  alias ScoresApi.Games

  describe "games" do
    alias ScoresApi.Games.Game

    @valid_attrs %{high_pts_to_win: true, players: ["raj", "somu"], title: "some title", user_id: 42}
    @update_attrs %{high_pts_to_win: false, players: [], title: "some updated title", user_id: 43}
    @invalid_attrs %{high_pts_to_win: nil, players: nil, title: nil, user_id: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Games.create_game()

      game
    end

    test "list_games/1 returns all games" do
      game = game_fixture()
      assert Games.list_games(42) == [game]
    end


    test "list_game_ids/1 returns all game ids of a user" do
      game1 = game_fixture()
      game2 = game_fixture()
      assert Games.list_game_ids(42) == [game1.id, game2.id]
    end


    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Games.create_game(@valid_attrs)
      assert game.high_pts_to_win == true
      assert game.players == ["raj", "somu"]
      assert game.title == "some title"
      assert game.user_id == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = Games.update_game(game, @update_attrs)
      assert game.high_pts_to_win == false
      assert game.players == []
      assert game.title == "some updated title"
      assert game.user_id == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end
end
