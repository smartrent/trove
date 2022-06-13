defmodule Trove.Helper do
  def take_deep(_map, nil), do: nil

  def take_deep(map, nested_atom_list) do
    flat_list = get_flat_atom_list(nested_atom_list)

    map
    |> Map.take(flat_list)
    |> Enum.reduce(%{}, &take_reduce_filtered(&1, &2, nested_atom_list))
  end

  defp take_reduce_filtered({k, v}, acc, nested_atom_list) when is_map(v),
    do: Map.put(acc, k, take_deep(v, nested_atom_list[k]))

  defp take_reduce_filtered({k, v}, acc, _nested_atom_list), do: Map.put(acc, k, v)

  def drop_deep(_map, nil), do: nil

  def drop_deep(map, nested_atom_list) do
    only_atom_list = get_only_atom_list(nested_atom_list)
    IO.inspect(only_atom_list, label: 'only_atom_list', limit: :infinity)

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

  def get_flat_atom_list(nested_atom_list) do
    Enum.map(nested_atom_list, &get_atom_key/1)
  end

  defp get_atom_key({atom_key, _atom_value}), do: atom_key
  defp get_atom_key(atom_key), do: atom_key

  def get_only_atom_list(nested_atom_list) do
    Enum.filter(nested_atom_list, &(!is_tuple(&1)))
  end
end
