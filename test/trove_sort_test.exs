defmodule TroveSortTest do
  """
  mix test test/trove_sort_test.exs
  """

  use TroveTest.RepoCase

  alias Fixtures.{
    Organization,
    Person,
    Vehicle,
    ParkingSpot
  }

  setup do
    {:ok, org1} =
      Repo.insert(%Organization{
        name: "Travis's Trucks",
        people: [
          %Person{first_name: "Ben", last_name: "Ates", age: 24},
          %Person{first_name: "Travis", last_name: "Bates", age: 27},
          %Person{first_name: "Travis", last_name: "Cates", age: 29},
          %Person{first_name: "Travis", last_name: "Dates", age: 30}
        ]
      })

    %{org1: org1}
  end

  describe "Sort" do
    test "asc ages", %{org1: org1} do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :age]
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Ates"
    end

    test "desc ages", %{org1: org1} do
      result =
        Person
        |> Trove.search!(%{},
          sort: [desc: :age]
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Dates"
    end

    test "asc ages with filter", %{org1: org1} do
      result =
        Person
        |> Trove.search!(%{first_name: "Travis"},
          sort: [asc: :age]
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Bates"
    end
  end
end
