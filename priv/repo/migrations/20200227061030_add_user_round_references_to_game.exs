defmodule ScoresApi.Repo.Migrations.AddUserRoundReferencesToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      modify :user_id, references(:users), null: false
      modify :round_id, references(:rounds), null: true
    end

  end
end
