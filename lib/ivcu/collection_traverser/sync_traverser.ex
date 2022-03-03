defmodule IVCU.CollectionTraverser.SyncTraverser do
  @moduledoc """
  Synchronously `IVCU.CollectionTraverser` implementation without
  exception handling.

  > #### Info {: .info}
  >
  > It returns after the first failed operation.
  """

  @behaviour IVCU.CollectionTraverser

  @impl true
  def traverse(enum, fun) when is_function(fun, 1) do
    result =
      Enum.reduce(enum, {:ok, []}, fn x, macc ->
        with {:ok, acc} <- macc,
             {:ok, y} <- fun.(x) do
          {:ok, [y | acc]}
        end
      end)

    with {:ok, reversed} <- result do
      {:ok, Enum.reverse(reversed)}
    end
  end
end
