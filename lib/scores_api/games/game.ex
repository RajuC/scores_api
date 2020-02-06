defmodule ScoresApi.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :high_pts_to_win, :boolean, default: false
    field :players, {:array, :string}
    field :title, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :players, :user_id, :high_pts_to_win])
    |> validate_required([:title, :players, :user_id, :high_pts_to_win])
  end
end
