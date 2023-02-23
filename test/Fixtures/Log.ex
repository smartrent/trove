defmodule Fixtures.Log do
  use Ecto.Schema

  schema "logs" do
    field(:message, :string)
    timestamps()
  end
end
