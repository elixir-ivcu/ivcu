defmodule IVCU.Definition do
  @moduledoc ~S"""
  An interface for file processing.

  ## Example

  Suppose we have defined [storage](`IVCU.Storage`) and
  [converter](`IVCU.Converter`) modules as `MyApp.FileStorage` and
  `MyApp.ImageConverter` respectively. Then we can provide a specific
  definition for some images.

      defmodule MyApp.Image do
        @behaviour IVCU.Definition

        def versions, do: [:thumb, :original]
        def storage, do: MyApp.FileStorage
        def converter, do: MyApp.ImageConverter

        def validate(%{filename: filename}) do
          if Path.extname(filename) in ~w(.png .jpg .jpeg) do
            :ok
          else
            {:error, :invalid_image_extension}
          end
        end

        def filename(version, filename) do
          extname = Path.extname(filename)
          base = filename |> String.replace(extname, "")
          "#{base}_#{version}#{extname}"
        end
      end

  Using that definition you get two file formats: `:thumb` and
  `:original` and pass only files with `.png`, `.jpg`, or `.jpeg`
  extensions.

  Also you stored filenames will be looking like
  `<original base filename>_<version>.<original extension>`.
  """

  alias IVCU.File

  @typedoc """
  A name for the version of the processed image.
  """
  @type version :: atom

  @doc """
  Return [Storage](`IVCU.Storage`) module.
  """
  @callback storage :: module

  @doc """
  Return [Converter](`IVCU.Converter`) module.
  """
  @callback converter :: module

  @doc """
  Check if the file is allowed to be processed and put into a
  storage.
  """
  @callback validate(File.t()) :: :ok | {:error, term}

  @doc """
  Return a list of versions.

  > #### Note {: .info}
  >
  > If you provide `:original` among versions, the file with this
  > version won't be modified by the converter.
  """
  @callback versions :: [version]

  @doc """
  Get a new filename for the provided version.
  """
  @callback filename(version, String.t()) :: String.t()
end
