defmodule Fixtures.OrganizationPerson do
  use Ecto.Schema

  alias Fixtures.{Person, Organization}

  @primary_key false
  schema "organizations_people" do
    belongs_to(:person, Person)
    belongs_to(:organization, Organization)
  end
end
