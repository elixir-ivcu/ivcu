defmodule IVCU.Storage.LocalTest do
  use ExUnit.Case, async: true

  defmodule Storage do
    use IVCU.Storage.Local, otp_app: :ivcu
  end

  describe "put/1 definded via __using__/1" do
    test "writes files with content" do
      filename = IVCU.File.random_filename()
      path = "./uploads/#{filename}"
      on_exit(fn -> File.rm!(path) end)

      file = %IVCU.File{filename: filename, content: <<255, 255>>}
      assert :ok = Storage.put(file)
      assert <<255, 255>> = File.read!(path)
    end

    test "writes files with path" do
      source_filename = IVCU.File.random_filename()
      filename = IVCU.File.random_filename()
      source_path = "./uploads/#{source_filename}"
      File.write!(source_path, <<255, 255>>)
      path = "./uploads/#{filename}"

      on_exit(fn ->
        File.rm!(source_path)
        File.rm!(path)
      end)

      file = %IVCU.File{filename: filename, path: source_path}
      assert :ok = Storage.put(file)
      assert <<255, 255>> = File.read!(path)
    end
  end

  describe "delete/1 definded via __using__/1" do
    test "deletes the file" do
      filename = IVCU.File.random_filename()
      path = "./uploads/#{filename}"
      File.write!(path, <<255, 255>>)

      on_exit(fn ->
        if File.exists?(path) do
          File.rm!(path)
        end
      end)

      file = %IVCU.File{filename: filename}
      assert :ok = Storage.delete(file)
      refute File.exists?(path)
    end
  end

  describe "url/1 defined via __using__/1" do
    test "returns file path" do
      filename = IVCU.File.random_filename()
      file = %IVCU.File{filename: filename}
      assert Storage.url(file) == "./uploads/#{filename}"
    end
  end
end
