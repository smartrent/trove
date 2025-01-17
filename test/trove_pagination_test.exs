defmodule TrovePagniationTest do
  @moduledoc """
  mix test test/trove_pagination_test.exs
  """

  use TroveTest.RepoCase

  alias Fixtures.{
    Organization,
    Person,
    Vehicle,
    ParkingSpot
  }

  setup_all do
    Repo.insert(%Organization{
      name: "Travis's Trucks",
      people: [
        %Person{first_name: "Ben", last_name: "Ates", age: 24},
        %Person{first_name: "Travis", last_name: "Bates", age: 27},
        %Person{first_name: "Travis", last_name: "Cates", age: 29},
        %Person{first_name: "Travis", last_name: "Dates", age: 30},
        %Person{first_name: "Travis", last_name: "Eates", age: 27},
        %Person{first_name: "Travis", last_name: "Fates", age: 29},
        %Person{first_name: "Travis", last_name: "Gates", age: 30},
        %Person{first_name: "Travis", last_name: "Hates", age: 30},
        %Person{first_name: "Travis", last_name: "Iates", age: 30},
        %Person{first_name: "Travis", last_name: "Jates", age: 30},
        %Person{first_name: "Dalton", last_name: "ZZZ", age: 27},
        %Person{first_name: "Dalton", last_name: "ZZZ", age: 29},
      ]
    })

    :ok
  end

  describe "Pagination" do
    test "default page limit" do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          page: 1
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Ates"
      assert length(result) == 10
    end

    test "page limit more than num of records" do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          limit: 100,
          page: 1
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Ates"
      assert length(result) == 12
    end

    test "set page limit" do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          page: 1,
          limit: 5
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Ates"
      assert length(result) == 5
    end

    # ensure that the limit always works with the page option
    test "set page limit param order" do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          limit: 5,
          page: 1
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "Ates"
      assert length(result) == 5
    end

    test "set page and offset mutually exclusive" do
      assert_raise ArgumentError, fn ->
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          offset: 1,
          page: 1
        )
        |> Repo.all()
      end
    end

    test "set offset limit params" do
      result =
        Person
        |> Trove.search!(%{},
          sort: [asc: :last_name],
          limit: 5,
          offset: 10
        )
        |> Repo.all()

      [person1 | rest] = result

      assert person1.last_name == "ZZZ"
      assert length(result) == 2
    end
  end
end
