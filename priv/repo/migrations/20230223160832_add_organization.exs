defmodule TroveTest.Repo.Migrations.AddOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
    end

    create table(:organizations_people) do
      add :organization_id, references(:organizations)
      add :person_id, references(:people)
    end
  end
end
