# Start the Ecto.Repo application
{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(TroveTest.Repo, :temporary)
{:ok, _pid} = TroveTest.Repo.start_link()

Ecto.Adapters.SQL.Sandbox.mode(TroveTest.Repo, :manual)

ExUnit.start(exclude: [:skip])
