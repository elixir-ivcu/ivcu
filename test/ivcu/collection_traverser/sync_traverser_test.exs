defmodule IVCU.CollectionTraverser.SyncTraverserTest do
  use ExUnit.Case

  alias IVCU.CollectionTraverser.SyncTraverser

  describe "traverse/2" do
    test "successfully applies actions to collection items" do
      assert SyncTraverser.traverse([1, 2, 3], fn x -> {:ok, x + 1} end) ==
               {:ok, [2, 3, 4]}
    end

    test "fails on the first failure" do
      assert SyncTraverser.traverse([1, 2, 3], fn x ->
               if rem(x, 2) == 0 do
                 {:error, "#{x} is even"}
               else
                 {:ok, x + 1}
               end
             end) == {:error, "2 is even"}
    end
  end
end