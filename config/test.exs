use Mix.Config

config :trove, TroveTest.Repo,
  username: "db",
  password: "db",
  database: "trove_test",
  hostname: "localhost",
  port: 5600,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger,
  backends: [:console],
  compile_time_purge_matching: [[lower_than: :debug]]
