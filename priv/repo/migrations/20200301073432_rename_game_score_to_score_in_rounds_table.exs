defmodule ScoresApi.Repo.Migrations.RenameGameScoreToScoreInRoundsTable do
  use Ecto.Migration

  def change do
    rename table(:rounds), :game_score, to: :score
  end
end
