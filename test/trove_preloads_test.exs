defmodule TrovePreloadsTest do
  use TroveTest.RepoCase

  alias Fixtures.Log

  test "Log query - no filters" do
    # Repo.insert(%Log{message: "First test log"})
    # Repo.insert(%Log{message: "Second test log"})
    # Repo.insert(%Log{message: "Third test log"})
    # Repo.insert(%Log{message: "Forth test log"})

    result =
      Log
      |> Trove.search()
      |> Repo.all()

    [l1 | _rest] = result

    assert l1.message == "First test log"
  end
end
