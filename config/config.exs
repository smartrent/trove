use Mix.Config

import_config "#{Mix.env()}.exs"

config :trove, ecto_repos: [TroveTest.Repo]
