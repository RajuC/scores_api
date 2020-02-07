defmodule ScoresApi.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias ScoresApi.Repo

  alias ScoresApi.Games.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games(user_id)
      [%Game{}, ...]

  """
  def list_games(user_id) do
    query = from u in Game, where: u.user_id == ^user_id
    query
      |> Repo.all()
  end



## =======

def list_game_ids(user_id) do
  query = from u in Game, where: u.user_id == ^user_id, select: u.id
  query
    |> Repo.all()
end


##========

def list_games_scores(userId) do
  query = from u in Game, where: u.user_id == ^userId, select: {u.id, u.title, u.inserted_at, u.high_pts_to_win}
  query
    |> Repo.all()
    |> Enum.map(fn({game_id, title, timestamp, high_pts_to_win}) ->
                  m_scores        = game_id         |> ScoresApi.Scores.list_scores_by_game_id!()
                  t_s             = m_scores        |> ScoresApi.Utils.cal_total_scores()
                  leading_player  = high_pts_to_win |> ScoresApi.Utils.get_leading_player(t_s)
                  player_wins     = m_scores        |> ScoresApi.Utils.cal_player_wins()
                  total_rounds    = m_scores        |> ScoresApi.Utils.get_total_rounds()
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

##==========





  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end
end
