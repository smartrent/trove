defmodule Trove.Helper do
  alias Inflex

  @spec map_to_kv_list(map() | any()) :: list()
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

  @spec get_atom_suffix(atom()) :: atom()
  def get_atom_suffix(atom) do
    atom
    |> to_string()
    |> String.split("_")
    |> List.last()
    |> String.to_atom()
  end

  @spec atom_matches(atom(), list(atom()) | atom()) :: boolean()
  def atom_matches(atom_a, list) when is_list(list),
    do: Enum.any?(list, &atom_matches(atom_a, &1))

  def atom_matches(atom_a, atom_b), do: atom_a == atom_b

  # TODO please refactor to be more readable
  # Finds an atom in a list of atoms that is similar to the given atom
  # but returns false if the found atom is exactly the same as the given atom
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

  @spec atom_contains(atom(), list(atom()) | atom() | String.t()) :: boolean() | {:ok, atom()}
  def atom_contains(atom_a, list) when is_list(list) do
    case Enum.find(list, &atom_contains(atom_a, &1)) do
      nil -> false
      found_atom -> {:ok, found_atom}
    end
  end

  def atom_contains(atom_a, atom_b) when is_atom(atom_b),
    do: String.contains?(to_string(atom_a), to_string(atom_b))

  def atom_contains(atom, str), do: String.contains?(to_string(atom), str)


  @spec take_deep(map(), list(atom()) | nil) :: map()
  def take_deep(_map, nil), do: nil

  def take_deep(map, nested_atom_list) do
    flat_list = get_flat_atom_list(nested_atom_list)

    map
    |> Map.take(flat_list)
    |> Enum.reduce(%{}, &take_reduce_filtered(&1, &2, nested_atom_list))
  end

  @spec take_reduce_filtered({atom(), map() | any()}, map(), list(atom())) :: map()
  defp take_reduce_filtered({k, v}, acc, nested_atom_list) when is_map(v),
    do: Map.put(acc, k, take_deep(v, nested_atom_list[k]))

  defp take_reduce_filtered({k, v}, acc, _nested_atom_list), do: Map.put(acc, k, v)

  # TODO: This is not quite working. The goal was to drop any fields from
  # the nested map that didn't exist in the nested list. ie the opposite of the above function `take_deep`
  def drop_deep(_map, nil), do: nil

  def drop_deep(map, nested_atom_list) do
    only_atom_list = get_only_atom_list(nested_atom_list)

    map
    |> Map.drop(only_atom_list)
    |> Enum.reduce(%{}, &drop_reduce_filtered(&1, &2, nested_atom_list))
  end

  defp drop_reduce_filtered({k, v}, acc, nested_atom_list) when is_map(v) do
    case drop_deep(v, nested_atom_list[k]) do
      nil -> acc
      value -> Map.put(acc, k, value)
    end
  end

  defp drop_reduce_filtered({k, v}, acc, _nested_atom_list), do: Map.put(acc, k, v)

  @spec get_flat_atom_list(list(atom())) :: list(atom())
  def get_flat_atom_list(nested_atom_list) do
    Enum.map(nested_atom_list, &get_atom_key/1)
  end

  @spec get_atom_key({atom(), any()} | atom()) :: atom()
  defp get_atom_key({atom_key, _atom_value}), do: atom_key
  defp get_atom_key(atom_key), do: atom_key

  @spec get_only_atom_list(list(map() | any())) :: list(atom())
  def get_only_atom_list(nested_atom_list) do
    Enum.filter(nested_atom_list, &(!is_tuple(&1)))
  end
end
