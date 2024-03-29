defmodule TroveTest.Repo.Migrations.CreateVehicle do
  use Ecto.Migration

  def change do
    create table(:vehicles) do
      add :make, :string
      add :model, :string
      add :year, :integer
      add :color, :string
      add :license_plate, :string
      add :date_registered, :utc_datetime_usec

      add :person_id, references(:people)
    end
  end
end
