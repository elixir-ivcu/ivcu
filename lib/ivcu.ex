defmodule IVCU do
  @moduledoc """
  Provides an API to validate, convert, and save files to abstract
  storages.

  ## Usage

  Suppose you have [a definition](`IVCU.Definition`) `MyApp.Image`.
  Then you can save a file from `Plug.Upload` struct like this.

      def save(%Plug.Upload{path: path}) do
        path
        |> IVCU.File.from_path()
        |> IVCU.save(MyApp.Image)
      end

  See [Getting Started](./guides/getting_started.md) guide for more
  information.
  """

  alias IVCU.File

  @doc """
  Save the file with provided definition.

  ## Algorithm

  - validate the original file;
  - generate new filenames;
  - apply transformations to the file providing new filenames;
  - put the new files in the storage.

  > #### Note {: .info}
  >
  > `definition` must implement [Definition](`IVCU.Definition`)
  > behaviour.

  > #### Note {: .info}
  >
  > Expected order of files is the same as order in which versions
  > were provided in the `definition`.
  """
  @spec save(File.t(), module) :: {:ok, [File.t()]} | {:error, term}
  def save(file, definition) when is_atom(definition) do
    with :ok <- definition.validate(file) do
      do_save(file, definition)
    end
  end

  defp do_save(file, definition) do
    traverse(definition.versions(), fn version ->
      new_filename = definition.filename(version, file.filename)

      with {:ok, converted} <-
             definition.converter().convert(file, version, new_filename),
           :ok <- definition.storage().put(converted) do
        definition.converter().clean!(converted)
        {:ok, converted}
      end
    end)
  end

  @doc """
  Delete files from the storage.

  ## Algorithm

  - generate filenames for versions specified in the `definition`
    module;
  - delete the files from the storage.

  > #### Note {: .info}
  >
  > `definition` must implement [Definition](`IVCU.Definition`)
  > behaviour.
  """
  @spec delete(File.t(), module) :: :ok | {:error, term}
  def delete(file, definition) when is_atom(definition) do
    with {:ok, _} <- do_delete(file, definition) do
      :ok
    end
  end

  defp do_delete(file, definition) do
    traverse(definition.versions(), fn version ->
      filename = definition.filename(version, file.filename)

      with :ok <- definition.storage().delete(%{file | filename: filename}) do
        {:ok, nil}
      end
    end)
  end

  @doc """
  Return urls to access all the versions of the file in the storage.

  > #### Note {: .info}
  >
  > `definition` must implement [Definition](`IVCU.Definition`)
  > behaviour.
  """
  @spec urls(File.t(), module) :: %{required(atom) => url} when url: String.t()
  def urls(file, definition) when is_atom(definition) do
    for version <- definition.versions(), into: %{} do
      filename = definition.filename(version, file.filename)
      {version, definition.storage().url(%{file | filename: filename})}
    end
  end

  defp traverse(enum, fun) when is_function(fun, 1) do
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
