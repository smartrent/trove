defmodule TroveTest.Repo.Migrations.CreateLog do
  use Ecto.Migration

  def change do
    create table(:log) do
      add :message, :string

      timestamps()
    end
  end
end
