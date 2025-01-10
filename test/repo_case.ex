defmodule TroveTest.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias TroveTest.Repo

      import Ecto
      import Ecto.Query
      import TroveTest.RepoCase
    end
  end

  setup_all tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TroveTest.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(TroveTest.Repo, {:shared, self()})
    end

    :ok
  end
end
