defmodule Fixtures.Organization do
  use Ecto.Schema

  alias Fixtures.{Person, OrganizationPerson}

  schema "organizations" do
    many_to_many(:people, Person, join_through: OrganizationPerson)

    field(:name, :string)
  end
end
