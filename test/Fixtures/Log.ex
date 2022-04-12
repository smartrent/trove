defmodule Fixtures.Log do
  use Ecto.Schema

  schema "log" do
    field(:message, :string)
    timestamps()
  end
end
