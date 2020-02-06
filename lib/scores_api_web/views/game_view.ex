defmodule ScoresApiWeb.GameView do
  use ScoresApiWeb, :view
  alias ScoresApiWeb.GameView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{id: game.id,
      title: game.title,
      players: game.players,
      user_id: game.user_id,
      high_pts_to_win: game.high_pts_to_win}
  end


  def render("g_s_index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game_scores.json")}
  end

  def render("game_scores.json", %{game: game}) do
    %{
        game_id:          game.id,
        title:            game.title,
        scores:           game.scores,
        leading_player:   game.leading_player,
        total_scores:     game.total_scores,
        high_pts_to_win:  game.high_pts_to_win,
        timestamp:        game.timestamp
      }
  end

end
