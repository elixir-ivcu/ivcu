defmodule IVCU.MixProject do
  use Mix.Project

  def project do
    [
      app: :ivcu,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "guides/getting_started.md",
        "guides/using_with_ecto.md",
        "guides/using_with_phoenix.md"
      ],
      groups_for_modules: [
        Utils: [IVCU.Converter.CMD, IVCU.Storage.Local],
        Internal: [
          IVCU.Converter,
          IVCU.Storage,
          IVCU.CollectionTraverser,
          IVCU.CollectionTraverser.AsyncTraverser,
          IVCU.CollectionTraverser.SyncTraverser
        ],
        Errors: [
          IVCU.Converter.CMD.InvalidFormatError,
          IVCU.Converter.CMD.UnknownVersionError
        ]
      ]
    ]
  end
end
