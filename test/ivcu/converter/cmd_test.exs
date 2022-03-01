defmodule IVCU.Converter.CMDTest do
  use ExUnit.Case, async: true

  defmodule DoubleConverter do
    use IVCU.Converter.CMD,
      args: %{
        thumb: ["sh", "-c", "cat $1 $1 > $2", "$0", :input, :output]
      }
  end

  describe "convert/3 defined via __using__/1" do
    test "applies the command to the input file with content" do
      input_filename = IVCU.File.random_filename()
      input_path = Path.join("/tmp", input_filename)
      output_filename = IVCU.File.random_filename()
      output_path = Path.join("/tmp", output_filename)
      File.write!(input_path, <<255, 255>>)

      on_exit(fn ->
        File.rm!(input_path)
        File.rm!(output_path)
      end)

      file = IVCU.File.from_path(input_path)

      assert {:ok, %{path: output_path}} =
               DoubleConverter.convert(file, :thumb, output_filename)

      assert <<255, 255, 255, 255>> = File.read!(output_path)
    end

    test "applies the command to an input file with content" do
      output_filename = IVCU.File.random_filename()
      output_path = Path.join("/tmp", output_filename)

      on_exit(fn ->
        File.rm!(output_path)
      end)

      file = IVCU.File.from_content(<<255, 255>>)

      assert {:ok, %{path: output_path}} =
               DoubleConverter.convert(file, :thumb, output_filename)

      assert <<255, 255, 255, 255>> = File.read!(output_path)
    end

    test "leaves :original file with a path without transformation" do
      input_filename = IVCU.File.random_filename()
      input_path = Path.join("/tmp", input_filename)
      output_filename = IVCU.File.random_filename()
      output_path = Path.join("/tmp", output_filename)
      File.write!(input_path, <<255, 255>>)

      on_exit(fn ->
        File.rm!(input_path)
        File.rm!(output_path)
      end)

      file = IVCU.File.from_path(input_path)

      assert {:ok, %{path: output_path}} =
               DoubleConverter.convert(file, :original, output_filename)

      assert <<255, 255>> = File.read!(output_path)
    end

    test "leaves :original file with content without transformation" do
      output_filename = IVCU.File.random_filename()
      output_path = Path.join("/tmp", output_filename)

      on_exit(fn ->
        File.rm!(output_path)
      end)

      file = IVCU.File.from_content(<<255, 255>>)

      assert {:ok, %{path: output_path}} =
               DoubleConverter.convert(file, :original, output_filename)

      assert <<255, 255>> = File.read!(output_path)
    end
  end
end
