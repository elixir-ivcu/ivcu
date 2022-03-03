defmodule IVCU.CollectionTraverser do
  @moduledoc """
  An interface for a strategy that handles applying multiple actions
  on a collection.

  It may be configured via application configuration.

      config :ivcu,
        collection_traverser: IVCU.CollectionTraverser.SyncTraverser

  The configuration above is default.

  > #### Warning {: .warning}
  >
  > You only need to implement this behaviour if you are not satisfied
  > with already implemented ones. Default is
  > `IVCU.CollectionTraverser.SyncTraverser`.
  """

  @type result(a, b) :: {:ok, a} | {:error, b}

  @doc ~S"""
  Apply the function to the collection and return result.

  ## Example

  Imagine we have a module `Collection` that implements this
  behaviour. Then we could do the following.

      iex(1)> Collection.traverse([1, 2, 3], fn x -> {:ok, x + 1} end)
      {:ok, [2, 3, 4]}
      iex(2)> Collection.traverse([1, 2, 3], fn x ->
      ...(2)>   if rem(x, 2) == 0 do
      ...(2)>     {:error, "#{x} is even"}
      ...(2)>   else
      ...(2)>     {:ok, x + 1}
      ...(2)>   end
      ...(2)> end)
      {:error, "2 is even"}
  """
  @callback traverse(Enumerable.t(), (term -> result(a, b))) ::
              result([a], b)
            when a: term, b: term
end
