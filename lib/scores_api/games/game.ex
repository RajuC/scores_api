defmodule ScoresApi.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :high_pts_to_win, :boolean, default: false
    field :players, {:array, :string}
    field :title, :string
    has_many :rounds, ScoresApi.Rounds.Round
    belongs_to :user, ScoresApi.Users.User

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :players, :high_pts_to_win])
    |> validate_required([:title, :players, :high_pts_to_win])
  end
end
