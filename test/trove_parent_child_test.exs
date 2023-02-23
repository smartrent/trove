defmodule TroveParentChildTest do
  use TroveTest.RepoCase

  alias Fixtures.{
    Person,
    Vehicle
  }

  @tag :skip
  test "Person query - find by child vehicle" do
    {:ok, person1} = Repo.insert(%Person{first_name: "Tad", last_name: "S", age: 26})
    {:ok, person2} = Repo.insert(%Person{first_name: "E", last_name: "S", age: 26})

    {:ok, vehicle} =
      Repo.insert(%Vehicle{
        people_id: person1.id,
        make: "Rivian",
        model: "R1",
        year: 2022,
        color: "Blue",
        license_plate: "123456",
        date_registered: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    [p] =
      Person
      |> Trove.search!(%{
        vehicle: %{
          make: "Rivian"
        }
      })
      |> Repo.all()

    assert p.first_name == "Tad"
  end

  @tag :skip
  test "Person query - could not find by child vehicle" do
    {:ok, person1} = Repo.insert(%Person{first_name: "Tad", last_name: "S", age: 26})
    {:ok, person2} = Repo.insert(%Person{first_name: "E", last_name: "S", age: 26})

    {:ok, vehicle} =
      Repo.insert(%Vehicle{
        people_id: person1.id,
        make: "Rivian",
        model: "R1",
        year: 2022,
        color: "Blue",
        license_plate: "123456",
        date_registered: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    records =
      Person
      |> Trove.search!(%{
        vehicle: %{
          make: "Toyota"
        }
      })
      |> Repo.all()

    refute Enum.any?(records)
  end
end
