defmodule ScoresApiWeb.RoundView do
  use ScoresApiWeb, :view
  alias ScoresApiWeb.RoundView

  def render("index.json", %{rounds: rounds}) do
    %{data: render_many(rounds, RoundView, "round.json")}
  end

  def render("show.json", %{round: round}) do
    %{data: render_one(round, RoundView, "round.json")}
  end

  def render("round.json", %{round: round}) do
    %{id: round.id,
      game_id: round.game_id,
      round_num: round.round_num,
      game_score: round.game_score,
      players: round.players}
  end
end
