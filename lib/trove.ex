defmodule Trove do
  @moduledoc """
  Trove is an Ecto search library.
  """

  require Logger

  import Ecto.Query

  alias Inflex
  alias Trove.Filter

  # @spec _has_defined_schema?(any()) :: boolean
  # defp _has_defined_schema?(module) do
  #   function_exported?(module, :__schema__, 1) or function_exported?(module, :__schema__, 2)
  # end

  # %{ field_of_module: value, relation: %{ field_of_relation: value }, relation_field_of_relation: value }

  @spec search(any(), list(), list(atom())) :: Query.t()
  def search(module, filters \\ %{}, preloads \\ []) do
    filter_list =
      module
      # Get all of the module's possible filters
      |> get_available_filters()
      |> IO.inspect(label: 'available_filters', limit: :infinity)
      # Validate and clean arg filters - remove any filter that does not match the module list (and type?)
      |> validate_filters(filters)
      # Transform filters to key value list
      # ie: [id: 1, message: "hello"]
      |> map_to_kv_list()
      |> IO.inspect(label: 'filter_list', limit: :infinity)

    module
    |> create_base_query()
    |> apply_filters(module, filter_list)
  end

  # def add_custom_filter(key, function) do
  # end

  def get(module) do
    module
  end

  def apply_filters(query, []), do: query

  def apply_filters(query, %{}), do: query

  def apply_filters(query, module, filter_list) when is_list(filter_list) do
    where(query, ^filter_list)
  end

  # def apply_filters(query, module, filters) when is_list(filters) do
  #   Enum.reduce(filters, query, fn
  #     {field, value}, acc when not is_nil(value) and value != "" ->
  #       apply_filter({field, value}, acc)

  #     _, acc ->
  #       acc
  #   end)
  # end

  # def apply_filter({field, value}, query) do
  #   where(query, [__module__: m], m[^field] == ^value)
  # end

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

  # Get a key value list of associations
  # [{:association_key, :related_module}]
  def get_associations(module) do
    :associations
    |> module.__schema__()
    |> Enum.map(fn a ->
      am = module.__schema__(:association, a)
      {a, am.related}
    end)
  end

  def build_filter_map(module) do
    module
    |> get_field_map()
    |> Enum.map(&Filter.from_tuple/1)
  end

  # Creates a list of atoms concatenated with the associated key
  # Also adds the regular nested list of fields under the associated key
  # ie [:vehicle_id, :vehicle_make, vehicle: [:id, :make]]
  def build_alternative_association_filters({association_key, module}) do
    fields = get_fields(module)
    singular_association_key = get_singular_atom(association_key)

    fields
    |> Enum.map(&concat_atoms(singular_association_key, &1))
    |> Kernel.++([{singular_association_key, fields}])
  end

  def get_available_filters(module) do
    fields = get_fields(module)

    module
    |> get_associations()
    |> Enum.map(&build_alternative_association_filters/1)
    |> Kernel.++(fields)
    |> List.flatten()
  end

  def validate_filters(fields, filters) do
    # need to normalize filters first
    %{valid: valid, invalid: invalid} =
      Enum.reduce(filters, %{valid: %{}, invalid: %{}}, fn {key, value}, acc ->
        case Enum.member?(fields, key) do
          true -> Map.put(acc, :valid, Map.put(acc.valid, key, value))
          false -> Map.put(acc, :invalid, Map.put(acc.invalid, key, value))
        end
      end)

    if Enum.count(invalid) > 0 do
      Logger.warn(%{
        message: "Invalid filters for search on given module",
        available_filters: fields,
        invalid_filters: invalid
      })
    end

    valid
  end

  def create_base_query(module) do
    from(
      m in module,
      as: :__module__
    )
  end

  # def load_module(module, name) do
  #   from(
  #     m in module,
  #     as: name
  #   )
  # end

  def map_to_kv_list(map) do
    Enum.map(map, fn {key, value} ->
      case key do
        k when is_atom(k) -> {k, value}
        k -> {String.to_existing_atom(k), value}
      end
    end)
  end

  # is it unsafe to take an existing atom and create a modified new one?
  @spec concat_atoms(atom(), atom()) :: atom()
  def concat_atoms(a1, a2) do
    String.to_atom(to_string(a1) <> "_" <> to_string(a2))
  end

  @spec get_singular_atom(atom()) :: atom()
  def get_singular_atom(a),
    do:
      a
      |> to_string()
      |> Inflex.singularize()
      |> String.to_atom()

  @spec get_plural_atom(atom()) :: atom()
  def get_plural_atom(a),
    do:
      a
      |> to_string()
      |> Inflex.pluralize()
      |> String.to_atom()

  # @spec build_associated_field_name(atom(), atom()) :: atom()
  # def build_associated_field_name(association_key, field_name),
  #   do:
  #     association_key
  #     |> get_singular_atom()
  #     |> concat_atoms(field_name)
end
