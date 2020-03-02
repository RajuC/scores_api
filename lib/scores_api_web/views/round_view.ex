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
      score: round.score,
      players: round.players,
      inserted_at: round.inserted_at}
  end
end
