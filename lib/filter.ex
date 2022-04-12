defmodule Trove.Filter do
  @enforce_keys [:name, :type]
  defstruct([:name, :type, :owner])

  @spec from_tuple({String.t(), String.t()} | {String.t(), String.t(), module()}) ::
          %Trove.Filter{
            name: String.t(),
            type: String.t(),
            owner: module()
          }
  def from_tuple({name, type, owner}), do: %__MODULE__{name: name, type: type, owner: owner}
  def from_tuple({name, type}), do: %__MODULE__{name: name, type: type}
end
