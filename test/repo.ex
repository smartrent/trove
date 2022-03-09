defmodule TroveTest.Repo do
  use Ecto.Repo,
    otp_app: :trove,
    adapter: Ecto.Adapters.Postgres
end
