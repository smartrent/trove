defmodule TrovePreloadsTest do
  use TroveTest.RepoCase

  alias Fixtures.{
    Organization,
    Person,
    Vehicle,
    ParkingSpot
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
    [p1 | _rest] = o1.people
    assert p1.first_name == "Jeremiah"
  end

  test "Preloads - many association levels" do
    {:ok, org1} =
      Repo.insert(%Organization{
        name: "Chris's Car's",
        people: [
          %Person{
            first_name: "Chris",
            last_name: "Heninger",
            age: 27,
            vehicles: [
              %Vehicle{
                make: "Rivian",
                model: "R1",
                year: 2022,
                color: "Blue",
                license_plate: "123456",
                date_registered: DateTime.utc_now() |> DateTime.truncate(:second),
                parking_spots: [%ParkingSpot{name: "Chris's Man Cave", location: "Garage"}]
              }
            ]
          }
        ]
      })

    result =
      Organization
      |> Trove.search!(%{id: org1.id}, preloads: [people: [vehicles: [:parking_spots]]])
      |> Repo.all()

    [o1] = result

    assert o1.name == "Chris's Car's"
    assert length(o1.people) == 1

    [p1] = o1.people
    [v1] = p1.vehicles
    [ps1] = v1.parking_spots
    assert ps1.name == "Chris's Man Cave"
  end
end
