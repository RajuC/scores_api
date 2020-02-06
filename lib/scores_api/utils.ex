defmodule ScoresApi.Utils do


  alias ScoresApi.Scores
  # alias ScoresApi.Games.Score



  def make_key_for_map(map_val) do
    map_val |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end



  def cal_total_scores(scores) do
      scores
        |> Enum.reduce([], fn(%{score: p_scores}, total_scores) ->
                      add_scores(p_scores, total_scores)
                    end)
  end

  def get_leading_player(false, scores) do
    scores |> Enum.sort_by(&(&1.score))|> List.first()
  end
  def get_leading_player(true, scores) do
    scores |> Enum.sort_by(&(&1.score))|> List.last()
  end


  def store_initial_game_scores(%{id: gameId, players: players}) do
    scoreParams =
      %{game_id: gameId,
          players: %{active: players, inactive: []},
          round: 0,
          game_score: initiate_scores(players, [])
        }
    Scores.create_score(scoreParams)
  end


## ===========================================================
def initiate_scores([], playerScores), do: playerScores
def initiate_scores([player| rest], initialScores) do
  playerScore =
    initialScores
      |> Enum.concat([%{name: player, score: 0}])
  rest |> initiate_scores(playerScore)
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
