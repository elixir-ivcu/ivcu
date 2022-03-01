# Using with ecto

After you finished [Getting Started](./getting_started.md) guide, you
may be interested how to use this library with
[ecto](https://github.com/elixir-ecto/ecto). The general approach is
to link your files to some database entries.

## Defined schema

Suppose we have the following simple schema for users.

```elixir
defmodule MyApp.User do
  use Ecto.Schema

  alias Ecto.Changeset

  schema "users" do
    field :username, :string
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> Changeset.cast(attrs, [:username])
    |> Changeset.validate_required([:username])
  end
end
```

And this is the module responsible for busyness logic.

```elixir
defmodule MyApp.UserQueries do
  alias MyApp.{Repo, User}

  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

## Adding avatars to the schema

Now we want to be able to attach avatars. First we add `:string` field
to the schema and modify `MyApp.User.changeset/2` function.

```elixir
defmodule MyApp.User do
  use Ecto.Schema

  alias Ecto.Changeset

  schema "users" do
    field :username, :string
    field :avatar, :string
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> Changeset.cast(attrs, [:username, :avatar])
    |> Changeset.validate_required([:username, :avatar])
  end
end
```

## Handling avatar uploading

Then we add image processing logic to `MyApp.UserQueries`.

```elixir
defmodule MyApp.UserQueries do
  alias MyApp.{Repo, User}

  def create(attrs) do
    with {:ok, filename} <- handle_image(attrs) do
      do_create(%{attrs | "avatar" => filename})
    end
  end

  # This function is responsible for actual image uploading.
  defp handle_image(%{"avatar" => %Plug.Upload{path: path}}) do
    %{filename: filename} = file = IVCU.File.from_path(path)

    with {:ok, _} <- IVCU.save(file, MyApp.Image) do
      {:ok, filename}
    end
  end

  defp handle_image(_) do
    {:error, :avatar_is_missing}
  end

  # Here we moved actual call database interaction into a separate
  # function.
  defp do_create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

> #### Warning {: .warning}
>
> Of cause you can implement more sophisticated validations on the
> input. The code above provided for demonstration purposes only.
