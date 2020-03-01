defmodule ScoresApi.GamesTest do
  use ScoresApi.DataCase

  alias ScoresApi.Games
  alias ScoresApi.Users

  describe "games" do
    alias ScoresApi.Games.Game


    @valid_attrs %{high_pts_to_win: true, players: ["raj", "somu"], title: "some title"}
    @update_attrs %{high_pts_to_win: false, players: [], title: "some updated title", user_id: 43}
    @invalid_attrs %{high_pts_to_win: nil, players: nil, title: nil, user_id: nil}


    @create_user_attrs %{
      email: "email@email.com",
      name: "some name",
      password: "some password",
      password_confirmation: "some password"
    }

    def game_fixture(user) do
      {:ok, game} = Games.create_game(user, @valid_attrs)
      game
    end

    test "list_games/0 returns all games" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      [gamee] = Games.list_games(user)
      assert [game] == [gamee |> Map.put(:user, user)]
    end

    test "get_game!/1 returns the game with given id" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      assert game == Games.get_game!(game.id) |> Map.put(:user, user)
    end

    test "create_game/1 with valid data creates a game" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      assert {:ok, %Game{} = game} = Games.create_game(user, @valid_attrs)
      assert game.high_pts_to_win == true
      assert game.players == ["raj", "somu"]
      assert game.title == "some title"
    end

    test "create_game/1 with invalid data returns error changeset" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      assert {:error, %Ecto.Changeset{}} = Games.create_game(user, @invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      assert {:ok, %Game{} = game} = Games.update_game(user, game, @update_attrs)
      assert game.high_pts_to_win == false
      assert game.players == []
      assert game.title == "some updated title"
    end

    test "update_game/2 with invalid data returns error changeset" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Games.update_game(user, game, @invalid_attrs)
      assert game == Games.get_game!(game.id) |> Map.put(:user, user)
    end

    test "delete_game/1 deletes the game" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      {:ok, user} = Users.create_user(@create_user_attrs)
      game = game_fixture(user)
      assert %Ecto.Changeset{} = Games.change_game(game)
    end

  end
end
