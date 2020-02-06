defmodule ScoresApi.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :game_id, :integer
      add :round, :integer
      add :game_score, {:array, :map}
      add :players, :map

      timestamps()
    end

  end
end
