defmodule IVCU.Storage do
  @moduledoc """
  Interface module for file storage.

  > #### Warning {: .warning}
  >
  > Usually you don't need to implement storage yourself as there
  > already exists `IVCU.Storage.Local` helper. That's the reason this
  > module is marked as "internal".
  """

  alias IVCU.File

  @doc """
  Put the file to the storages.
  """
  @callback put(File.t()) :: :ok | {:error, term}

  @doc """
  Delete the file from the storage.
  """
  @callback delete(File.t()) :: :ok | {:error, term}

  @doc """
  Return url with which one can access the file in the storage.
  """
  @callback url(File.t()) :: String.t()
end
