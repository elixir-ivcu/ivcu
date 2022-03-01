defmodule IVCU.Converter do
  @moduledoc """
  Interface module for file convertation.

  > #### Warning {: .warning}
  >
  > Usually you don't need to implement converter yourself as there
  > already exists `IVCU.Converter.CMD` helper. That's
  > the reason this module is marked as "internal".
  """

  alias IVCU.File

  @doc """
  Trigger the convert action.

  > #### Note {: .info}
  >
  > When `version` is `:original` the command should be treated as a
  > special case where the file stays unchanged.
  """
  @callback convert(File.t(), version, new_filename) ::
              {:ok, File.t()} | {:error, term}
            when version: atom, new_filename: String.t()

  @doc """
  Remove a file produced by the converter.

  This action is triggered after storage performed `c:IVCU.Storage.put/1`
  call.
  """
  @callback clean!(File.t()) :: :ok
end
