defmodule ScoresApi.Rounds.Round do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rounds" do
    field :score, {:array, :map}
    field :players, :map
    field :round_num, :integer
    belongs_to :game, ScoresApi.Games.Game

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:round_num, :score, :players])
    |> validate_required([:round_num, :score, :players])
  end
end
