defmodule Fixtures.ParkingSpot do
  use Ecto.Schema

  alias Fixtures.{Vehicle, VehicleParkingSpot}

  schema "parking_spots" do
    many_to_many(:vehicle, Vehicle, join_through: VehicleParkingSpot)

    field(:name, :string)
    field(:location, :string)
  end
end
