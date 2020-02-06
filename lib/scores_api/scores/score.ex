defmodule ScoresApi.Scores.Score do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scores" do
    field :game_id, :integer
    field :game_score, {:array, :map}
    field :players, :map
    field :round, :integer

    timestamps()
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:game_id, :round, :game_score, :players])
    |> validate_required([:game_id, :round, :game_score, :players])
  end
end
