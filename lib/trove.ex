defmodule Trove do
  @moduledoc """
  Trove is a Ecto search library.
  """

  # @spec _has_defined_schema?(any()) :: boolean
  # defp _has_defined_schema?(module) do
  #   function_exported?(module, :__schema__, 1) or function_exported?(module, :__schema__, 2)
  # end

  @spec search(any(), list(atom())) :: Query.t()
  def search(module, preloads \\ []) do
    module.__schema__(:fields)
  end

  # def add_custom_filter(key, function) do
  # end

  def get(module) do
    module
  end
end
