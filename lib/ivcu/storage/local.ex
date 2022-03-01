defmodule IVCU.Storage.Local do
  @moduledoc """
  Provides a helper to generate a [storage](`IVCU.Storage`) that
  saves all the files localy.

  ## Usage

  First you need to define a configurable module for your storage.

      defmodule MyApp.FileStorage do
        use IVCU.Storage.Local, otp_app: :my_app
      end

  Then you need to proceed to configuration part.

      config :my_app, MyApp.FileStorage,
        dir: "./uploads"

  Now you can use your storage module in your
  [definition](`IVCU.Definition`).
  """

  @doc false
  defmacro __using__(opts) do
    otp_app = Keyword.get(opts, :otp_app) || raise ":otp_app key was expected"

    config =
      Application.get_env(otp_app, __CALLER__.module) ||
        raise "no configuration provided for #{otp_app}, #{__CALLER__.module}"

    dir =
      Keyword.get(config, :dir) ||
        raise "expected key :dir in #{otp_app}, #{__CALLER__.module} " <>
                "configuration"

    quote do
      @behaviour IVCU.Storage

      @impl IVCU.Storage
      def put(file) do
        unquote(__MODULE__).put(unquote(dir), file)
      end

      @impl IVCU.Storage
      def delete(file) do
        unquote(__MODULE__).delete(unquote(dir), file)
      end

      @impl IVCU.Storage
      def url(file) do
        unquote(__MODULE__).url(unquote(dir), file)
      end
    end
  end

  @doc false
  def put(dir, %{filename: filename, content: nil, path: src_path})
      when is_binary(filename) and is_binary(src_path) do
    dst_path = Path.join(dir, filename)
    dst_dir = Path.dirname(dst_path)
    File.mkdir_p!(dst_dir)
    File.cp!(src_path, dst_path)
  end

  @doc false
  def put(dir, %{filename: filename, content: content, path: nil})
      when is_binary(filename) and is_binary(content) do
    dst_path = Path.join(dir, filename)
    dst_dir = Path.dirname(dst_path)
    File.mkdir_p!(dst_dir)
    File.write!(dst_path, content, [:write, :binary])
  end

  @doc false
  def delete(dir, %{filename: filename}) when is_binary(filename) do
    File.rm!(Path.join(dir, filename))
  end

  @doc false
  def url(dir, %{filename: filename}) when is_binary(filename) do
    Path.join(dir, filename)
  end
end
