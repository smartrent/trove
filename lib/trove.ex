defmodule Trove do
  @moduledoc """
  Trove is an Ecto search library.
  """

  require Logger

  import Ecto.Query

  alias Inflex
  alias Trove.Filter
  alias Trove.Helper

  @spec search(any(), list(), list(atom())) :: Query.t()
  def search(module, filters \\ %{}, _preloads \\ []) do
    filter_list =
      module
      # Get all of the module's possible filters
      |> get_available_filters()
      # Validate and clean arg filters - remove any filter that does not match the module list (and type?)
      |> validate_filters(filters)
      # Normalize filters to have consistent shape
      |> normalize_filters(module)
      # Transform filters to key value list
      # ie: [id: 1, message: "hello"]
      |> Helper.map_to_kv_list()

    module
    |> create_base_query()
    |> apply_filters(module, filter_list)
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

  # This is not finished. It will need a macro to join the relations on the query
  def apply_relations_filter(query, module, {_relation_name, relation_filters}) do
    query
    |> where([], ^relation_filters)
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
    singular_association_key = Helper.get_singular_atom(association_key)

    fields
    |> Enum.map(&Helper.concat_atoms(singular_association_key, &1))
    |> Kernel.++([{singular_association_key, fields}])

    # use this for infinite nested relations
    # need to add cache of already visited relationships to avoid infinite loop
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

  # Filters
  # These functions could probably be made into a macro
  # That would possibly offer compile time warnings when
  # invalid filters are being used

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
      |> Enum.map(&Helper.get_singular_atom/1)

    Enum.reduce(filters, %{}, fn {k, v}, acc ->
      case Helper.atom_exclusively_contains(k, singular_association_keys) do
        false ->
          Map.put(acc, k, v)

        {:ok, parent_key} ->
          case Map.get(acc, parent_key) do
            nil -> Map.put(acc, parent_key, Map.put(%{}, Helper.get_atom_suffix(k), v))
            child -> Map.put(acc, parent_key, Map.put(child, Helper.get_atom_suffix(k), v))
          end
      end
    end)
  end

end
