defmodule Fixtures.VehicleParkingSpot do
  use Ecto.Schema

  alias Fixtures.{Vehicle, ParkingSpot}

  @primary_key false
  schema "vehicles_parking_spots" do
    belongs_to(:parking_spot, ParkingSpot)
    belongs_to(:vehicle, Vehicle)
  end
end
