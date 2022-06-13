defmodule Trove do
  @moduledoc """
  Trove is an Ecto search library.
  """

  require Logger

  import Ecto.Query

  alias Inflex
  alias Trove.Filter
  alias Trove.Helper

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
      |> normalize_filters(module)
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
    relations = Enum.filter(filter_list, &is_tuple/1)
    base_filters = Enum.filter(filter_list, &(!is_tuple(&1)))

    query
    |> where(^base_filters)
    |> apply_relations_filters(module, relations)
  end

  def apply_relations_filters(query, module, relations_list) do
    Enum.map(relations_list, &apply_relations_filter(query, module, &1))
  end

  def apply_relations_filter(query, module, {relation_name, relation_filters}) do
    query
    |> where([], ^relation_filters)
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

  def get_association(module, key) do
    module.__schema__(:association, key)
  end

  def get_associations(module) do
    module.__schema__(:associations)
  end

  # Get a key value list of associations
  # [{:association_key, :related_module}]
  def get_associations_map(module) do
    module
    |> get_associations()
    |> Enum.map(fn a ->
      am = get_association(module, a)
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

    # use this for infinite nested relations
    # need to add cache of already visited relationships
    # |> Kernel.++([
    #   {singular_association_key, get_available_filters(get_association(module, association_key))}
    # ])
  end

  def get_available_filters(module) do
    fields = get_fields(module)

    module
    |> get_associations_map()
    |> Enum.map(&build_alternative_association_filters/1)
    |> Kernel.++(fields)
    |> List.flatten()
  end

  def validate_filters(fields, filters) do
    invalid = find_invalid_filters(fields, filters)

    if Enum.count(invalid) > 0 do
      Logger.warn(%{
        message: "Invalid filters for search on given module",
        available_filters: fields,
        invalid_filters: invalid
      })
    end

    find_valid_filters(fields, filters)
  end

  # TODO find invalid filters to report to user
  def find_invalid_filters(fields, filters) do
    %{}
  end

  def find_valid_filters(fields, filters) do
    Helper.take_deep(filters, fields)
  end

  # TODO needs recursion
  def normalize_filters(filters, module) do
    singular_association_keys =
      module
      |> get_associations()
      |> Enum.map(&get_singular_atom/1)

    Enum.reduce(filters, %{}, fn {k, v}, acc ->
      case atom_exclusively_contains(k, singular_association_keys) do
        false ->
          Map.put(acc, k, v)

        {:ok, parent_key} ->
          case Map.get(acc, parent_key) do
            nil -> Map.put(acc, parent_key, Map.put(%{}, get_atom_suffix(k), v))
            child -> Map.put(acc, parent_key, Map.put(child, get_atom_suffix(k), v))
          end
      end
    end)
  end

  def create_base_query(module) do
    from(
      m in module,
      as: :__module__
    )
  end

  # make a macro for this
  # def join_module(query, module, name, join_type \\ :left) do
  #   join(
  #     query,
  #     join_type,
  #     [__module__: m],
  #     j in module
  #     on:
  #     # as: unquote(name)
  #   )
  # end

  def map_to_kv_list(map) when is_map(map) do
    Enum.map(map, fn {key, value} ->
      case key do
        k when is_atom(k) -> {k, map_to_kv_list(value)}
        k -> {String.to_existing_atom(k), map_to_kv_list(value)}
      end
    end)
  end

  def map_to_kv_list(value), do: value

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

  def get_atom_suffix(atom) do
    atom
    |> to_string()
    |> String.split("_")
    |> List.last()
    |> String.to_atom()
  end

  def atom_matches(atom_a, list) when is_list(list),
    do: Enum.any?(list, &atom_matches(atom_a, &1))

  def atom_matches(atom_a, atom_b), do: atom_a == atom_b

  # TODO please refactor to be more readable
  def atom_exclusively_contains(atom_a, list) when is_list(list) do
    case atom_contains(atom_a, list) do
      false ->
        false

      {:ok, found_atom} ->
        case found_atom != atom_a do
          true -> {:ok, found_atom}
          false -> false
        end
    end
  end

  def atom_contains(atom_a, list) when is_list(list) do
    case Enum.find(list, &atom_contains(atom_a, &1)) do
      nil -> false
      found_atom -> {:ok, found_atom}
    end
  end

  def atom_contains(atom_a, atom_b) when is_atom(atom_b),
    do: String.contains?(to_string(atom_a), to_string(atom_b))

  def atom_contains(atom, str), do: String.contains?(to_string(atom), str)
end
