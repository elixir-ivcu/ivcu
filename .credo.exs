%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Readability.BlockPipe, []},
        {Credo.Check.Readability.SinglePipe, []},
        {Credo.Check.Refactor.IoPuts, []}
      ]
    }
  ]
}
