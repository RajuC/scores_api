defmodule ScoresApi.UtilsTest do
  use ScoresApi.DataCase

  alias ScoresApi.Utils
  alias ScoresApi.Scores
  alias ScoresApi.Games


  @game1_attrs  %{high_pts_to_win: true, players: ["raj", "som"], title: "some title", user_id: 158}
  @game2_attrs  %{high_pts_to_win: false, players: ["raj", "som"], title: "some title", user_id: 158}

  @valid_score_attrs1_1 %{game_score: [%{"name"=> "raj", "score" => 30}, %{"name" => "som", "score" => 25}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 1}
  @valid_score_attrs1_2 %{game_score: [%{"name"=> "raj", "score" => 20}, %{"name" => "som", "score" => 45}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 2}

  @valid_score_attrs2_1 %{game_score: [%{"name"=> "raj", "score" => 0}, %{"name" => "som", "score" => 25}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 1}
  @valid_score_attrs2_2 %{game_score: [%{"name"=> "raj", "score" => 0}, %{"name" => "som", "score" => 5}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 2}


    def game_fixture(attrs \\ %{}) do
      {:ok, game1} =
        attrs
        |> Enum.into(@game1_attrs)
        |> Games.create_game()
      {:ok, game2} =
        attrs
        |> Enum.into(@game2_attrs)
        |> Games.create_game()

      {game1, game2}
    end

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(%{})
        |> Scores.create_score()
      score
    end


    test "list_games_scores/1 returns all games of a user with game_scores" do
      {game1, game2} = game_fixture()
      score_fixture(@valid_score_attrs1_1 |> Map.put(:game_id, game1.id))
      score_fixture(@valid_score_attrs1_2 |> Map.put(:game_id, game1.id))

      score_fixture(@valid_score_attrs2_1 |> Map.put(:game_id, game2.id))
      score_fixture(@valid_score_attrs2_2 |> Map.put(:game_id, game2.id))
      # IO.inspect(score)
      # IO.inspect(score2)
      g1_scores = ScoresApi.Scores.list_scores_by_game_id!(game1.id)
      g2_scores = ScoresApi.Scores.list_scores_by_game_id!(game2.id)

      game_scores =
        [
          %{
            game_id:        game1.id,
            title:          game1.title,
            scores:         g1_scores,
            leading_player: %{name: "som", score: 70},
            total_scores:   [%{name: "raj", score: 50}, %{name: "som", score: 70}],
            high_pts_to_win: game1.high_pts_to_win,
            timestamp:      game1.inserted_at,
            player_wins:    [%{name: "som", winning_rounds: 1}, %{name: "raj", winning_rounds: 1}],
            total_rounds:   2
            },
          %{
            game_id:        game2.id,
            title:          game2.title,
            scores:         g2_scores,
            leading_player: %{name: "raj", score: 0},
            total_scores:   [%{name: "raj", score: 0}, %{name: "som", score: 30}],
            high_pts_to_win: game2.high_pts_to_win,
            timestamp:      game2.inserted_at,
            player_wins:    [%{name: "raj", winning_rounds: 2}],
            total_rounds:   2
          }
      ]
      assert Utils.list_games_scores(158) == game_scores
    end


    test "list_games_scores/1 returns all games of a invalid user with game_scores" do
      assert Utils.list_games_scores(1588) == []
    end


    test "make_key_for_map/1 convert string keys to atom keys" do
      str_key_map = %{"name"=> "raj", "score" => 0}
      assert Utils.make_key_for_map(str_key_map) ==  %{name: "raj", score: 0}
    end

    test "make_key_for_map/1 convert string keys to atom keys for a empty map" do
      str_key_map = %{}
      assert Utils.make_key_for_map(str_key_map) ==  %{}
    end


  describe "validate_game_score/2" do

    test "validate_game_score/2  validates the game_scores if game not available for user" do
      game_fixture()

      assert Utils.validate_game_score(158, %{"game_id" => 168, "round" => 0}) == {:error, :game_not_available_for_user}
    end

    test "validate_game_score/2  validates the game_scores if round already exists for game" do
        {game1, _game2} = game_fixture()

        score1_1 = score_fixture(@valid_score_attrs1_1 |> Map.put(:game_id, game1.id))
        # score1_2 = score_fixture(@valid_score_attrs1_2 |> Map.put(:game_id, game1.id))

      assert Utils.validate_game_score(158, %{"game_id" => game1.id, "round" => score1_1.round}) == {:error, :round_already_exists_for_game}
    end

    test "validate_game_score/2  validation success for a game_id and a new round" do
        {game1, _game2} = game_fixture()
        _score1_1 = score_fixture(@valid_score_attrs1_1 |> Map.put(:game_id, game1.id))
        score1_2 = score_fixture(@valid_score_attrs1_2 |> Map.put(:game_id, game1.id))

      assert Utils.validate_game_score(158, %{"game_id" => game1.id, "round" => score1_2.round + 1 }) == :ok

    end

  end

end
