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
          %Person{first_name: "Travis", last_name: "Dates", age: 30},
          %Person{first_name: "Dalton", last_name: "AAA", age: 27},
          %Person{first_name: "Dalton", last_name: "aAA", age: 29},
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

    test "asc names with filter", %{org1: org1} do
      result =
        Person
        |> Trove.search!(%{first_name: "Dalton"},
          sort: [asc: :last_name]
        )
        |> Repo.all()

        [p1, p2] = result

        assert p1.last_name == "AAA"
        assert p2.last_name == "aAA"

      result2 =
        Person
        |> Trove.search!(%{first_name: "Dalton"},
          sort: [desc: :last_name]
        )
        |> Repo.all()

      [q1, q2] = result2

      assert q1.last_name == "aAA"
      assert q2.last_name == "AAA"
    end
  end
end
