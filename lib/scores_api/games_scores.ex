defmodule ScoresApi.GamesScores do

  alias ScoresApi.Repo
  alias ScoresApi.GamesScores

  # alias ScoresApi.Games.Game
  import Ecto.Query, warn: false

## ===========================================================
  def list_games_scores(user) do
    user
      |> Repo.preload([:games])
      |> Map.get(:games)
      |> pmap(&GamesScores.game_scores/1)

  end


## ===========================================================
  def pmap(col, func) do
    col
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end


## ===========================================================
  def game_scores(game) do
    rounds          = game        |> get_rounds()
    t_s             = GamesScores |> Task.async(:calculate_t_s, [rounds]) |> Task.await()
    leading_player  = GamesScores |> Task.async(:get_leading_player, [game.high_pts_to_win, t_s])
    player_wins     = GamesScores |> Task.async(:cal_player_wins, [rounds])

      %{
        game_id:          game.id,
        title:            game.title,
        high_pts_to_win:  game.high_pts_to_win,
        timestamp:        game.inserted_at,
        rounds:           rounds,
        total_rounds:     length(rounds),
        total_scores:     t_s,
        leading_player:   leading_player  |> Task.await(),
        player_wins:      player_wins     |> Task.await()

      }
  end


## =============================================================

  def get_rounds(game) do
    game
      |> Repo.preload([:rounds])
      |> Map.get(:rounds)
      |> Enum.map(fn(x) -> %{score:  make_keys_atom_for_g_s(x.score),
                             round_num:   x.round_num,
                             time:        x.inserted_at} end)

  end

##=============================================================
  def calculate_t_s([]), do: []
  def calculate_t_s([round|rounds]) do
      # r_s = score.score |> Enum.map(fn x -> make_key_for_map(x) end)
      rounds
        |> Enum.reduce(round.score, fn(%{score: p_scores}, total_scores) ->
                              update_score_by_name(p_scores, total_scores)
                    end)
  end
## ===========================================================
  def cal_player_wins([]), do: []
  def cal_player_wins(rounds) do
      rounds
        |> Enum.reduce([], fn(%{score: p_scores, round_num: round}, winning_rounds) ->
                      get_winning_rounds(%{score: p_scores, round_num: round}, winning_rounds)
                    end)
  end

  ## ===========================================================
  def get_leading_player(false, []), do: %{}
  def get_leading_player(false, scores) do
    scores |> Enum.sort_by(&(&1.score))|> hd()
  end
  def get_leading_player(true, scores) do
    scores |> Enum.sort_by(&(&1.score))|> List.last()
  end


##=============================================================
## priv functions
## ===========================================================

## ===========================================================
  defp make_key_atom_for_map(map_val) do
    map_val |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

## ===========================================================
  defp make_keys_atom_for_g_s([]), do: []
  defp make_keys_atom_for_g_s(list) do
    list |> Enum.map(fn(x) -> make_key_atom_for_map(x) end)
  end

## ===========================================================
  defp get_winning_rounds(%{round_num: 0}, w_r),  do: w_r
  defp get_winning_rounds(%{score: p_scores}, w_r) do
    %{name: winner} = p_scores |> Enum.sort_by(&(&1.score))|> hd()
     winner_map = w_r |> Enum.find(&(&1.name == winner))
      case winner_map do
        nil                           ->
          w_r |> Enum.concat([%{name: winner, winning_rounds: 1 }])
        %{winning_rounds: no_of_wins} ->
          updated_winner_map = winner_map |> Map.put(:winning_rounds,  no_of_wins + 1)
          w_r |> List.delete(winner_map) |> Enum.concat([updated_winner_map])
      end
  end


## ===========================================================
  defp update_score_by_name([], t_s), do: t_s
  defp update_score_by_name([%{name: player, score: p_score} | rest_scores], t_s) do
    [update_p_ts] = for %{name: p, score: s} <- t_s, player == p, do: %{name: p, score: s + p_score}
    rest_p_ts  = for %{name: p} = p_ts <- t_s, player != p, do: p_ts
    update_score_by_name(rest_scores, [update_p_ts| rest_p_ts])
  end


end
