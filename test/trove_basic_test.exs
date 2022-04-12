defmodule TroveBasicTest do
  use TroveTest.RepoCase

  alias Fixtures.Log

  test "Log query - no filters" do
    Repo.insert(%Log{message: "First test log"})
    Repo.insert(%Log{message: "Second test log"})
    Repo.insert(%Log{message: "Third test log"})
    Repo.insert(%Log{message: "Forth test log"})

    result =
      Log
      |> Trove.search()
      |> Repo.all()

    [l1 | _rest] = result

    assert l1.message == "First test log"
  end

  test "Log query - message filter" do
    Repo.insert(%Log{message: "Find me"})
    Repo.insert(%Log{message: "Leave me"})

    result =
      Log
      |> Trove.search(%{message: "Find me"})
      |> Repo.all()

    [r1] = result
    assert r1.message == "Find me"
  end
end
