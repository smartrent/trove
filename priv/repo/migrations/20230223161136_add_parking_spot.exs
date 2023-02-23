defmodule TroveTest.Repo.Migrations.AddParkingSpot do
  use Ecto.Migration

  def change do
    create table(:parking_spots) do
      add :address, :string
    end

    create table(:vehicles_parking_spots) do
      add :vehicle_id, references(:vehicles)
      add :parking_spot_id, references(:parking_spots)
    end
  end
end
