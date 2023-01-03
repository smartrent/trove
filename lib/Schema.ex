defmodule Trove.Schema do
  @spec get_fields(atom) :: any
  def get_fields(module) do
    module.__schema__(:fields)
  end

  @spec get_field_type(atom, atom) :: any
  def get_field_type(module, field_name) do
    module.__schema__(:type, field_name)
  end

  @spec get_field_map(atom) :: any
  def get_field_map(module) do
    module
    |> get_fields()
    |> Enum.map(&{&1, get_field_type(module, &1)})
  end

  @spec get_association(atom, atom) :: any
  def get_association(module, key) do
    module.__schema__(:association, key)
  end

  @spec get_associations(atom) :: any
  def get_associations(module) do
    module.__schema__(:associations)
  end

  # Get a key value list of associations
  # [{:association_key, :related_module}]
  @spec get_associations_map(atom) :: any
  def get_associations_map(module) do
    module
    |> get_associations()
    |> Enum.map(fn a ->
      am = get_association(module, a)
      {a, am.related}
    end)
  end
end
