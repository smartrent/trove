import Config

config :trove, default_page_size: 25

import_config "#{config_env()}.exs"

config :trove, ecto_repos: [TroveTest.Repo]
