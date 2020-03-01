defmodule ScoresApiWeb.GameView do
  use ScoresApiWeb, :view
  alias ScoresApiWeb.GameView

  def render("index.json", %{games: games}) do
    render_many(games, GameView, "game.json")
  end

  def render("show.json", %{game: game}) do
    render_one(game, GameView, "game.json")
  end

  def render("game.json", %{game: game}) do
    %{id: game.id,
      title: game.title,
      players: game.players,
      high_pts_to_win: game.high_pts_to_win}
  end

  def render("g_s_index.json", %{games: games}) do
    render_many(games, GameView, "game_scores.json")
  end

  def render("game_scores.json", %{game: game}) do
    %{
        title:            game.title,
        leading_player:   game.leading_player,
        player_wins:      game.player_wins,
        total_rounds:     game.total_rounds,
        high_pts_to_win:  game.high_pts_to_win,
        timestamp:        game.timestamp,
        game_id:          game.game_id,
        rounds:           game.rounds,
        total_scores:     game.total_scores

      }
  end

end
