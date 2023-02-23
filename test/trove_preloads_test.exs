defmodule TrovePreloadsTest do
  use TroveTest.RepoCase

  alias Fixtures.{
    Organization,
    Person
  }

  test "Preloads - one association" do
    {:ok, org1} =
      Repo.insert(%Organization{
        name: "Jeremiah's Jalopy's",
        people: [
          %Person{first_name: "Jeremiah", last_name: "Tabb", age: 25},
          %Person{first_name: "Chris", last_name: "Heninger", age: 27}
        ]
      })

    result =
      Organization
      |> Trove.search!(%{id: org1.id}, preloads: [:people])
      |> Repo.all()

    [o1] = result

    assert o1.name == "Jeremiah's Jalopy's"
    assert length(o1.people) == 2
  end
end
