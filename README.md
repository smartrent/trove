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

- [x] Search by fields on schema
- [ ] Search by relations fields
  - [ ] Search one relation level deep
  - [ ] Search infinite levels deep
- [ ] Add custom filters to search
- [ ] Paginated results
- [ ] Docs
- [ ] Schema information caching (ie Cache available_filters per module/schema)
- [ ] OR filters validation built from macros

## Reference

https://yos.io/2016/04/28/writing-and-publishing-elixir-libraries/  
https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection  
https://hexdocs.pm/ecto_shorts/EctoShorts.html

## Notes

I'd like to eventually add support for better field searching to match this api:
https://hexdocs.pm/ecto_shorts/EctoShorts.html#module-actions

The ideal api would look something like:

```elixir
Person
  |> Trove.search(%{
    first_name: %{ilike: "Scott"},
    vehicle: %{
      make: "Rivian"
      year: %{gte: 2022}
    },
    page: 1,
    limit: 10,
    preloads: [vehicle: :parking_reservation]
  })
  |> Repo.all()
```
