defmodule IVCU.File do
  @moduledoc """
  Internal file representation used everywhere else in the library.
  """

  defstruct ~w[path filename content]a

  @typedoc """
  File representation used in the library.

  File must always have a `:name`, even though it may not have
  `:path` or `:content` depending on the way it was produced.
  """
  @type t :: %__MODULE__{
          path: Path.t() | nil,
          filename: Path.t(),
          content: binary | nil
        }

  @doc """
  Create new [File](`t:IVCU.File.t/0`) struct from path.

  This function is supposed to be used when you need to save a file
  already stored on the filesystem.

  ## Example

      iex(1)> IVCU.File.from_path("./uploads/file.txt")
      %IVCU.File{
        filename: "file.txt",
        path: "./uploads/file.txt",
        content: nil
      }
  """
  @spec from_path(Path.t()) :: t
  def from_path(path) when is_binary(path) do
    filename = Path.basename(path)
    %__MODULE__{path: path, filename: filename}
  end

  @doc """
  Create new [File](`t:IVCU.File.t/0`) struct with only name present.

  This function is supposed to be used for deletion of an already
  existing file or for getting an URL for the file.

  ## Example

      iex(1)> IVCU.File.from_name("file.txt")
      %IVCU.File{filename: "file.txt", path: nil, content: nil}

  > #### Warning {: .warning}
  >
  > It cannot be used to save a new file, because we need some source
  > from which we copy the file.
  """
  def from_name(filename) when is_binary(filename) do
    %__MODULE__{filename: filename}
  end

  @doc """
  Create new [File](`t:IVCU.File.t/0`) struct from file content.

  This function is supposed to be used when you need to save some
  binary payload as a file.

  ## Example

      iex(1)> %IVCU.File{path: nil, content: <<255, 255>>} =
      ...(1)>   IVCU.File.from_content(<<255, 255>>)

  > #### Note {: .info}
  >
  > This function puts random `:filename` with no extension
  > into the file.
  """
  @spec from_content(binary) :: t
  def from_content(content) when is_binary(content) do
    filename = random_filename()
    %__MODULE__{filename: filename, content: content}
  end

  @doc """
  Replaces `:filename` with random filename with no extension.

  It's usefull when you need to override original filename to
  keep filenames unique.

  ## Example

      iex(1)> file = IVCU.File.from_path("./uploads/file.txt")
      iex(2)> %IVCU.File{
      ...(2)>   content: nil,
      ...(2)>   path: "./uploads/file.txt",
      ...(2)>   filename: filename
      ...(2)> } = IVCU.File.with_random_filename(file)
      iex(3)> filename != file.filename
      true
  """
  def with_random_filename(%{filename: original_filename} = file) do
    extname = Path.extname(original_filename)
    filename = "#{random_filename()}#{extname}"
    %__MODULE__{file | filename: filename}
  end

  @doc """
  Return random filename.
  """
  def random_filename do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
    |> String.replace("=", "")
  end
end
