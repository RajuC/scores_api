defmodule ScoresApi.Utils do

  alias ScoresApi.Utils
  alias ScoresApi.Scores
  alias ScoresApi.Games
  alias ScoresApi.Repo
  alias ScoresApi.Games.Game
  import Ecto.Query, warn: false




  ## ===========================================================

  def list_games_scores(user_id) do
    query = from u in Game, where: u.user_id == ^user_id, select: {u.id, u.title, u.inserted_at, u.high_pts_to_win}
    query
      |> Repo.all()
      |> pmap(fn({game_id, title, timestamp, high_pts_to_win}) ->
                    m_scores        = game_id         |> ScoresApi.Scores.list_scores_by_game_id!()
                    t_s             = m_scores        |> cal_total_scores()
                    leading_player  = high_pts_to_win |> get_leading_player(t_s)
                    player_wins     = m_scores        |> cal_player_wins()
                    total_rounds    = m_scores        |> get_total_rounds()
                    %{
                      game_id:        game_id,
                      title:          title,
                      scores:         m_scores,
                      leading_player: leading_player,
                      total_scores:   t_s,
                      high_pts_to_win: high_pts_to_win,
                      timestamp:      timestamp,
                      player_wins:    player_wins,
                      total_rounds:   total_rounds
                    }
                  end)
  end


  def validate_game_score(user_id, %{"game_id" => game_id, "round" => round}) do
    user_id
      |> Games.list_game_ids
      |> Enum.member?(game_id)
      |> validate_round(game_id,round)
  end

  def make_key_for_map(map_val) do
    map_val |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end


  def pmap(col, func) do
    col
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end


  def initiate_scores(player) do
   %{name: player, score: 0}
  end

  def store_initial_game_scores(%{id: gameId, players: players}) do
    scoreParams =
      %{game_id: gameId,
          players: %{active: players, inactive: []},
          round: 0,
          game_score: players |> pmap(&Utils.initiate_scores/1)
        }
    Scores.create_score(scoreParams)
  end

##=============================================================
## priv functions
##=============================================================
  defp cal_total_scores(scores) do
      scores
        |> Enum.reduce([], fn(%{score: p_scores}, total_scores) ->
                              add_scores(p_scores, total_scores)
                    end)
  end



  ## ===========================================================
  defp get_total_rounds(scores) do
    scores
      |> Enum.reduce(-1, fn(_p_scores, total_rounds) ->
                    total_rounds + 1
                  end)
  end

  ## ===========================================================
  defp cal_player_wins(scores) do
      scores
        |> Enum.reduce([], fn(%{score: p_scores, round: round}, winning_rounds) ->
                      get_winning_rounds(%{score: p_scores, round: round}, winning_rounds)
                    end)
  end


  ## ===========================================================
  defp get_winning_rounds(%{round: 0}, w_r),  do: w_r
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
  defp get_leading_player(false, scores) do
    scores |> Enum.sort_by(&(&1.score))|> hd()
  end
  defp get_leading_player(true, scores) do
    scores |> Enum.sort_by(&(&1.score))|> List.last()
  end


## ===========================================================
defp validate_round(true, game_id, round) do
  valid_round =
    game_id
      |> Scores.list_rounds_by_game_id!
      |> Enum.member?(round)
  case valid_round do
    true -> {:error, :round_already_exists_for_game}
    false -> :ok
  end
end
defp validate_round(false, _game_id, _round) do
  {:error, :game_not_available_for_user}
end



## ===========================================================
  defp add_scores(p_scores, []), do: p_scores
  defp add_scores([], t_s), do: t_s
  defp add_scores([p_score| p_scores], t_s) do
    mod_t_s = t_s |> update_score_by_name(p_score)
    add_scores(p_scores, mod_t_s)
  end

## ===========================================================
  defp update_score_by_name(t_s, %{name: player, score: p_score} ) do
    prev_t_s = t_s |>Enum.find(fn u -> u.name == player end)
    prev_score =
      prev_t_s
        |> Map.get(:score)
    new_score =
      case p_score do
        "NA" -> prev_score;
        _    -> p_score + prev_score
      end
     t_s |> List.delete(prev_t_s) |> Enum.concat([%{name: player, score: new_score}])

  end

end
