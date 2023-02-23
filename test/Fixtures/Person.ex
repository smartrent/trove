defmodule Fixtures.Person do
  use Ecto.Schema

  alias Fixtures.{Vehicle, Organization, OrganizationPerson}

  schema "people" do
    has_many(:vehicles, Vehicle)
    many_to_many(:organizations, Organization, join_through: OrganizationPerson)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:age, :integer)
  end
end
