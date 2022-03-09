defmodule TroveTest do
  use TroveTest.RepoCase
  doctest Trove

  alias Fixtures.{
    Person,
    Vehicle
  }

  test "Person has correct fields" do
    assert Trove.search(Person) == [:id, :first_name, :last_name, :age]
  end

  test "Vehicle has correct fields" do
    assert Trove.search(Vehicle) == [
             :id,
             :person_id,
             :make,
             :model,
             :year,
             :color,
             :license_plate,
             :date_registered
           ]
  end

  test "Person query" do
    res1 =
      Person
      |> Trove.get()
      |> Repo.all()

    assert res1 == []

    Repo.insert(%Person{first_name: "Tad", last_name: "Scritchfield", age: 26})

    res2 =
      Person
      |> Trove.get()
      |> Repo.all()

    assert [new_person] = res2
  end
end
