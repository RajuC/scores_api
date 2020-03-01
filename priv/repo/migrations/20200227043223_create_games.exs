defmodule ScoresApi.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :title, :string
      add :players, {:array, :string}
      add :user_id, :integer
      add :round_id, :integer
      add :high_pts_to_win, :boolean, default: false, null: false

      timestamps()
    end

  end
end
