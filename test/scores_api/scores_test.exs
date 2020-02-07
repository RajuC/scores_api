defmodule ScoresApi.ScoresTest do
  use ScoresApi.DataCase

  alias ScoresApi.Scores

  describe "scores" do
    alias ScoresApi.Scores.Score
    alias ScoresApi.Utils


    @valid_attrs %{game_id: 42, game_score: [%{"name"=> "raj", "score" => 30}, %{"name" => "som", "score" => 25}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 1}
    @valid_attrs_2 %{game_id: 42, game_score: [%{"name"=> "raj", "score" => 30}, %{"name" => "som", "score" => 25}], players: %{"active" => ["raj", "som"], "inactive" => []}, round: 2}
    @invalid_attrs %{game_id: nil, game_score: nil, players: nil, round: nil}

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Scores.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Scores.list_scores() == [score]
    end

    test "list_rounds_by_game_id!/1 returns the number of rounds played in the game" do
      score = score_fixture()
      _r2_score = score_fixture(@valid_attrs_2)
      assert Scores.list_rounds_by_game_id!(score.game_id) == [1,2]
    end

    test "list_scores_by_game_id!/1 returns all the scores of a game" do
      r1_score = score_fixture()
      r2_score = score_fixture(@valid_attrs_2)
      r1_s = r1_score.game_score |> Enum.map(&(Utils.make_key_for_map(&1)))
      r2_s = r2_score.game_score |> Enum.map(&(Utils.make_key_for_map(&1)))
      r1_p = r1_score.players |> Utils.make_key_for_map
      r2_p = r2_score.players |> Utils.make_key_for_map
      [r1,r2] = Scores.list_scores_by_game_id!(r1_score.game_id)
      assert [r1.score, r2.score]     == [r1_s, r2_s]
      assert [r1.round, r2.round]     == [r1_score.round, r2_score.round]
      assert [r1.players, r2.players] == [r1_p, r2_p]
    end


    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Scores.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = Scores.create_score(@valid_attrs)
      assert score.game_id == 42
      assert score.game_score == [%{"name" => "raj", "score" => 30}, %{"name" => "som", "score" => 25}]
      assert score.players == %{"active" => ["raj", "som"], "inactive" => []}
      assert score.round == 1
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scores.create_score(@invalid_attrs)
    end


    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Scores.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Scores.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Scores.change_score(score)
    end
  end
end
