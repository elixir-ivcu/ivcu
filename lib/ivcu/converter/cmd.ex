defmodule IVCU.Converter.CMD do
  @moduledoc """
  Provides a helper to generate a [converter](`IVCU.Converter`) that
  uses any cmd converter for files (`convert` binary from
  [imagemagick](https://imagemagick.org/) in example).

  ## Usage

  To use the converter you need to define a module.

      defmodule MyApp.ImageConverter do
        use IVCU.Converter.CMD,
          args: %{
            thumb: [
              "convert",
              :input,
              "-thumbnail",
              "100x100^",
              "-gravity",
              "center",
              "-extent",
              "100x100",
              :output
            ]
          }
      end

  `:args` is a map where the commands for different versions are
  provided.

  `:input` and `:output` represent positions of input and output files
  for the command.

  Now you can use your storage module in your
  [definition](`IVCU.Definition`).
  """

  @doc false
  defmacro __using__(opts) do
    args = Keyword.get(opts, :args) || raise ":args key was expected"

    quote do
      @behaviour IVCU.Converter

      @impl IVCU.Converter
      defdelegate clean!(file), to: unquote(__MODULE__)

      @impl IVCU.Converter
      def convert(file, version, new_filename) do
        unquote(__MODULE__).convert(unquote(args), file, version, new_filename)
      end
    end
  end

  @doc false
  def clean!(%{path: path}) when is_binary(path) do
    File.rm!(path)
  end

  defmodule UnknownVersionError do
    @moduledoc """
    An error raised when your definition provides a version that
    was not specified in `IVCU.Converter.CMD` config.
    """

    defexception [:version]

    @impl Exception
    def message(%{version: version}) do
      "unknown version: #{version}"
    end
  end

  defmodule InvalidFormatError do
    @moduledoc """
    An error raised when a command in `IVCU.Converter.CMD` config
    has invalid format.
    """

    defexception [:cmd]

    @impl Exception
    def message(%{cmd: cmd}) do
      "invalid command format: #{inspect(cmd)}"
    end
  end

  @doc false
  def convert(args, file, version, new_filename)

  def convert(_, file, :original, new_filename) do
    output_path = Path.join("/tmp", new_filename)
    File.touch!(output_path)
    input_path = input_path(file)
    File.cp!(input_path, output_path)
    clean_input_file!(file, input_path)
    file = %IVCU.File{path: output_path, filename: new_filename}
    {:ok, file}
  end

  def convert(args, file, version, new_filename) do
    case args do
      %{^version => cmd} when is_list(cmd) ->
        do_convert(cmd, file, new_filename)

      %{^version => cmd} ->
        raise InvalidFormatError, cmd: cmd

      _ ->
        raise UnknownVersionError, version: version
    end
  end

  defp do_convert(cmd, file, new_filename) do
    output_path = Path.join("/tmp", new_filename)
    File.touch!(output_path)
    input_path = input_path(file)

    with :ok <- run_command(cmd, input_path, output_path) do
      clean_input_file!(file, input_path)
      file = %IVCU.File{path: output_path, filename: new_filename}
      {:ok, file}
    end
  end

  defp input_path(%{path: path, content: nil}) when is_binary(path) do
    path
  end

  defp input_path(%{path: nil, content: content, filename: filename})
       when is_binary(content) and is_binary(filename) do
    input_path = Path.join("/tmp", filename)
    File.write!(input_path, content)
    input_path
  end

  defp run_command(cmd, input_file, output_file) do
    [executable | args] =
      Enum.map(cmd, fn
        :input -> input_file
        :output -> output_file
        x -> x
      end)

    case System.cmd(executable, args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      {output, _} -> {:error, output}
    end
  end

  defp clean_input_file!(%{path: nil, content: content}, input_path)
       when is_binary(content) do
    File.rm!(input_path)
  end

  defp clean_input_file!(%{path: path}, _) when is_binary(path) do
    :ok
  end
end
