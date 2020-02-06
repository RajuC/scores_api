defmodule ScoresApi.ScoresTest do
  use ScoresApi.DataCase

  alias ScoresApi.Scores

  describe "scores" do
    alias ScoresApi.Scores.Score

    @valid_attrs %{game_id: 42, game_score: [], players: %{}, round: 42}
    @update_attrs %{game_id: 43, game_score: [], players: %{}, round: 43}
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

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Scores.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = Scores.create_score(@valid_attrs)
      assert score.game_id == 42
      assert score.game_score == []
      assert score.players == %{}
      assert score.round == 42
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scores.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, %Score{} = score} = Scores.update_score(score, @update_attrs)
      assert score.game_id == 43
      assert score.game_score == []
      assert score.players == %{}
      assert score.round == 43
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Scores.update_score(score, @invalid_attrs)
      assert score == Scores.get_score!(score.id)
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
