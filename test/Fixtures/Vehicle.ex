defmodule Fixtures.Vehicle do
  use Ecto.Schema

  alias Fixtures.{Person, ParkingSpot, VehicleParkingSpot}

  schema "vehicles" do
    belongs_to(:people, Person)
    many_to_many(:parking_spots, ParkingSpot, join_through: VehicleParkingSpot)

    field(:make, :string)
    field(:model, :string)
    field(:year, :integer)
    field(:color, :string)
    field(:license_plate, :string)
    field(:date_registered, :utc_datetime)
  end
end
