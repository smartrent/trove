defmodule Fixtures.Person do
  use Ecto.Schema

  alias Fixtures.Vehicle

  schema "person" do
    has_many(:vehicles, Vehicle)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:age, :integer)
  end
end
