# Getting Started

## Install

The package can be installed by adding `ivcu` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ivcu, "~> 0.1.0"}
  ]
end
```

## Define a storage

Storage is a module that implements `IVCU.Storage` behaviour.

The easiest option is to use `IVCU.Storage.Local`. If you want to
upload your files to S3, you may want to use `ivcu_s3_storage`.

```elixir
defmodule MyApp.LocalFileStorage do
  use IVCU.Storage.Local, otp_app: :my_app
end
```

## Define a converter

Converter is a module that implements `IVCU.Converter` behaviour.

IVCU provides `IVCU.Converter.CMD` that can be used to define
a converter that uses [imagemagick](https://imagemagick.org/)'s
`convert` binary.

```elixir
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
```

## Define a definition

To process a file in specific way you need to define a definition --
a module that implements `IVCU.Definition` behaviour.

```elixir
defmodule MyApp.Image do
  @behaviour IVCU.Definition

  def versions, do: [:thumb, :original]
  def storage, do: MyApp.LocalFileStorage
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
```

## Save a new file

```elixir
def save_upload(%Plug.Upload{path: path}) do
  path
  |> IVCU.File.from_path()
  |> IVCU.save(MyApp.Image)
end
```

## Get files' URLs

```elixir
def thumb_url(filename) do
  %{thumb: url} =
    filename
    |> IVCU.File.from_path()
    |> IVCU.urls()

  url
end
```

## Delete all versions of a file

```elixir
def delete_old_file(filename) do
  filename
  |> IVCU.File.from_path()
  |> IVCU.delete()
end
```
