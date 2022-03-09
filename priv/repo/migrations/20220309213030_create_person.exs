defmodule TroveTest.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:person) do
      add :first_name, :string
      add :last_name, :string
      add :age, :integer
    end
  end
end
