defmodule ScoresApi.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :game_id, :integer
      add :round_num, :integer
      add :game_score, {:array, :map}
      add :players, :map

      timestamps()
    end

  end
end
