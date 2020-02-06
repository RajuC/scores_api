defmodule ScoresApiWeb.ScoreView do
  use ScoresApiWeb, :view
  alias ScoresApiWeb.ScoreView

  def render("index.json", %{scores: scores}) do
    %{data: render_many(scores, ScoreView, "score.json")}
  end

  def render("show.json", %{score: score}) do
    %{data: render_one(score, ScoreView, "score.json")}
  end

  def render("score.json", %{score: score}) do
    %{id: score.id,
      game_id: score.game_id,
      round: score.round,
      game_score: score.game_score,
      players: score.players}
  end
end
