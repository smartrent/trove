defmodule Trove do
  @moduledoc """
  Trove is an Ecto search library.
  """

  import Ecto.Query

  alias Trove.Filter

  # @spec _has_defined_schema?(any()) :: boolean
  # defp _has_defined_schema?(module) do
  #   function_exported?(module, :__schema__, 1) or function_exported?(module, :__schema__, 2)
  # end

  @spec search(any(), list(), list(atom())) :: Query.t()
  def search(module, filters \\ %{}, preloads \\ []) do
    # fields = get_fields(module)

    module
    |> create_base_query()
    |> apply_filters(module, filters)
  end

  # def add_custom_filter(key, function) do
  # end

  def get(module) do
    module
  end

  def apply_filters(query, %{}), do: query

  def apply_filters(query, module, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {field, value}, acc when not is_nil(value) and value != "" ->
        apply_filter({field, value}, acc)

      _, acc ->
        acc
    end)
  end

  def apply_filter({field, value}, query) do
    where(query, [__module__: m], m[^field] == ^value)
  end

  # utils
  @spec get_fields(atom) :: any
  def get_fields(module) do
    module.__schema__(:fields)
  end

  def get_field_type(module, field_name) do
    module.__schema__(:type, field_name)
  end

  def get_field_map(module) do
    module
    |> get_fields()
    |> Enum.map(&{&1, get_field_type(module, &1)})
  end

  def get_relations(module) do
    module.__schema__(:associations)
  end

  def build_filter_map(module) do
    module
    |> get_field_map()
    |> Enum.map(&Filter.from_tuple/1)
  end

  def create_base_query(module) do
    from(
      m in module,
      as: :__module__
    )
  end
end
