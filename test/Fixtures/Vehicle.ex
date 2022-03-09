defmodule Fixtures.Vehicle do
  use Ecto.Schema

  alias Fixtures.Person

  schema "vehicle" do
    belongs_to(:person, Person)

    field(:make, :string)
    field(:model, :string)
    field(:year, :integer)
    field(:color, :integer)
    field(:license_plate, :string)
    field(:date_registered, :utc_datetime)
  end
end
