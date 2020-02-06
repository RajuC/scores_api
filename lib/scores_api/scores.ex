defmodule ScoresApi.Scores do
  @moduledoc """
  The Scores context.
  """

  import Ecto.Query, warn: false
  alias ScoresApi.Repo

  alias ScoresApi.Scores.Score

  alias ScoresApi.Utils
  @doc """
  Returns the list of scores.

  ## Examples

      iex> list_scores()
      [%Score{}, ...]

  """
  def list_scores do
    Repo.all(Score)
  end

## ================

def list_scores_by_game_id!(game_id)do
  #   score = Score |> where(game_id: ^game_id) |> Repo.all()
  # IO.inspect("=========================== list_scores_by_game_id #{game_id}")
  query = from u in Score, where: u.game_id == ^game_id, select: {u.game_score, u.players, u.round, u.inserted_at}

  Repo.all(query) |> Enum.map(fn({score, players, round, time}) ->
    m_scores =    score |> Enum.map(fn(x) -> Utils.make_key_for_map(x) end)
    m_players = Utils.make_key_for_map(players)
    %{score:    m_scores,
      players:  m_players,
      round:    round,
      timestamp: time}
   end)
end

## ==============

  @doc """
  Gets a single score.

  Raises `Ecto.NoResultsError` if the Score does not exist.

  ## Examples

      iex> get_score!(123)
      %Score{}

      iex> get_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_score!(id), do: Repo.get!(Score, id)

  @doc """
  Creates a score.

  ## Examples

      iex> create_score(%{field: value})
      {:ok, %Score{}}

      iex> create_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_score(attrs \\ %{}) do
    %Score{}
    |> Score.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a score.

  ## Examples

      iex> update_score(score, %{field: new_value})
      {:ok, %Score{}}

      iex> update_score(score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_score(%Score{} = score, attrs) do
    score
    |> Score.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a score.

  ## Examples

      iex> delete_score(score)
      {:ok, %Score{}}

      iex> delete_score(score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_score(%Score{} = score) do
    Repo.delete(score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking score changes.

  ## Examples

      iex> change_score(score)
      %Ecto.Changeset{source: %Score{}}

  """
  def change_score(%Score{} = score) do
    Score.changeset(score, %{})
  end
end
