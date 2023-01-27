# 💎 Trove

> ⚠️ This package is still in development

A Composable Search Library for [Ecto](https://hexdocs.pm/ecto).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `trove` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:trove, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/trove](https://hexdocs.pm/trove).

## Example

```elixir
Log
  |> Trove.search(%{message: "Find me"})
  |> Repo.all()
```

## Development

Run `docker-compose up -d` to start the database.

Run `mix test` to run tests.

## Features

### 1.0

- [x] Search by fields on schema
- [ ] Preload relationships
- [ ] Sorting
- [ ] Paginated results

### 1.x

- [ ] Search with ilike, gte and other modifiers

### 1.x

- [ ] Search by relations fields
- [ ] Search one relation level deep

### 1.x

- [ ] Search "infinite" levels deep

### 1.x

- [ ] HTTP params transform util function

### 1.x

- [ ] Schema information caching (ie Cache available_filters per module/schema)
- [ ] ~Add custom filters to search~ can be added to the returned query
- [ ] ^ OR filters validation built from macros

## Reference

https://yos.io/2016/04/28/writing-and-publishing-elixir-libraries/  
https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection  
https://hexdocs.pm/ecto_shorts/EctoShorts.html

## Notes

I'd like to eventually add support for better field searching to match this api:
https://hexdocs.pm/ecto_shorts/EctoShorts.html#module-actions

The ideal api would look something like:

```elixir
# would it be possible to put this on the Person and if the schema model doesn't have it throw a validation error
# pass :all to allow all fields
# override-able in the search function?
# or just make it the only way to set the allowed fields
@allowed_fields Trove.allowed_fields(Person, [:first_name])

 search_terms = %{
    first_name: %{ilike: "Scott"},
    vehicle_make: "Rivian",
    vehicle: %{
      make: "Rivian"
      year: %{gte: 2022}
    }


# utility function (this is run in Trove.search before the query is created)
Trove.validate_search(Person, search_terms)

...
# Trove.search! pattern
Person
  |> Trove.search!(
    search_terms,
    page: 1,
    limit: 10,
    preloads: [vehicle: :parking_reservation]
    sort: [first_name: :asc]
    allowed_fields: allowed_fields
  )
  |> Repo.all()

# Trove.search pattern
case Trove.search(
  Person,
  search_terms,
  allowed_fields,
  pagination: %{page: 1, limit: 10}
  page: 1,
  limit: 10,
  preloads: [vehicle: :parking_reservation]
}) do
  {:ok, search} -> Repo.all()
  {:error, {:{type}, message}} -> message
end

...
total_count = Person
  |> Trove.search(search_terms)
  |> Repo.aggregate(:count)
```

### Challenges

- getting compile time helpers like ilike, gte, date between working
  > Should be solved by EctoShorts
- could be generating unoptimized queries
  > It may create marginally slower queries for basic searches but this is not meant to be used to
  > replace report type queries
- avoid making api params directly assignable to search terms
  > Solved by validation input
- validating user input
- avoiding infinitely recursive relation queries (especially for many-to-many)
  > Could be solved with a configurable limit
- error handling -> bubbling errors up to user.
  > Trove should handle as much as possible
