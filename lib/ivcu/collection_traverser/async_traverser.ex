defmodule IVCU.CollectionTraverser.AsyncTraverser do
  @moduledoc """
  This module implements `IVCU.CollectionTraverser` in asynchronous
  way making operations potentially faster.
  """

  @behaviour IVCU.CollectionTraverser

  @impl true
  def traverse(enum, fun) when is_function(fun, 1) do
    result =
      enum
      |> Task.async_stream(fun)
      |> Stream.map(fn {:ok, result} -> result end)
      |> Enum.reduce({:ok, []}, fn my, macc ->
        with {:ok, acc} <- macc,
             {:ok, y} <- my do
          {:ok, [y | acc]}
        end
      end)

    with {:ok, reversed} <- result do
      {:ok, Enum.reverse(reversed)}
    end
  end
end
