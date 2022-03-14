defmodule IVCUTest do
  use ExUnit.Case, async: true

  defmodule Storage do
    @behaviour IVCU.Storage

    @impl true
    def put(file) do
      send(self(), {:put, file})
      :ok
    end

    @impl true
    def delete(file) do
      send(self(), {:delete, file})
      :ok
    end

    @impl true
    def url(file) do
      file.filename
    end
  end

  defmodule Converter do
    @behaviour IVCU.Converter

    @impl true
    def convert(file, version, new_filename) do
      send(self(), {:convert, file, version, new_filename})
      {:ok, %{file | filename: new_filename}}
    end

    @impl true
    def clean!(file) do
      send(self(), {:clean, file})
      :ok
    end
  end

  defmodule Definition do
    def versions do
      [:thumb, :original]
    end

    def storage do
      Storage
    end

    def converter do
      Converter
    end

    def validate(%{filename: filename}) do
      if Path.extname(filename) in ~w(.png .jpg .jpeg) do
        :ok
      else
        {:error, :invalid_image_extension}
      end
    end

    def filename(version, %{filename: filename}) do
      extname = Path.extname(filename)
      base = String.replace(filename, extname, "")
      "#{base}_#{version}#{extname}"
    end
  end

  describe "save/2" do
    test "saves files to the storage" do
      assert {:ok, _files} =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.save(Definition)

      assert_receive {:put, %{filename: "file_thumb.jpg"}}
      assert_receive {:put, %{filename: "file_original.jpg"}}
    end

    test "converts files" do
      assert {:ok, _files} =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.save(Definition)

      assert_receive {:convert, %{filename: "file.jpg"}, :thumb,
                      "file_thumb.jpg"}

      assert_receive {:convert, %{filename: "file.jpg"}, :original,
                      "file_original.jpg"}
    end

    test "returns stored filenames" do
      assert {:ok, files} =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.save(Definition)

      assert [
               %{filename: "file_thumb.jpg"},
               %{filename: "file_original.jpg"}
             ] = files
    end

    test "cleans temporary files created by the converter" do
      assert {:ok, _files} =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.save(Definition)

      assert_receive {:clean, %{filename: "file_thumb.jpg"}}
      assert_receive {:clean, %{filename: "file_original.jpg"}}
    end
  end

  describe "delete/2" do
    test "deletes all the versions of the stored file" do
      assert :ok =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.delete(Definition)

      assert_receive {:delete, %{filename: "file_thumb.jpg"}}
      assert_receive {:delete, %{filename: "file_original.jpg"}}
    end

    test "doesn't call converter" do
      assert :ok =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.delete(Definition)

      refute_receive {:convert, %{filename: "file.jpg"}, "file_thumb.jpg"}
      refute_receive {:convert, %{filename: "file.jpg"}, "file_original.jpg"}
    end
  end

  describe "urls/2" do
    test "returns urls for all versions" do
      assert %{
               thumb: "file_thumb.jpg",
               original: "file_original.jpg"
             } =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.urls(Definition)
    end

    test "doesn't call converter" do
      assert %{} =
               "file.jpg"
               |> IVCU.File.from_path()
               |> IVCU.urls(Definition)

      refute_receive {:convert, %{filename: "file.jpg"}, "file_thumb.jpg"}
      refute_receive {:convert, %{filename: "file.jpg"}, "file_original.jpg"}
    end
  end
end
