# Using with Phoenix

After finishing [Using with ecto](./using_with_ecto.md) guide you may
be interested in interactions with
[Phoenix](https://github.com/phoenixframework/phoenix).

## Returning links to the user

We can guess that the action above was triggered somewhere in a
controller. Suppose we have standard JSON API with
Phoenix. For the client to be able to see links to the avatars we need
to add them to an appropriate view.

```elixir
defmodule MyAppWeb.UserView do
  alias MyApp.Image

  def render("user.json", %{user: user}) do
    %{original: original_path, thumb: thumb_path} =
      user.avatar
      |> IVCU.File.from_path()
      |> IVCU.urls(Image)

    base_url = Application.get_env(:my_app, :base_url)

    %{
      username: user.username,
      avatar: "#{base_url}#{original_path}",
      avatar_thumb: "#{base_url}#{thumb_path}",
    }
  end
end
```

> #### Note {: .info}
>
> For S3 storage you don't need to build full url as its storage
> returns full urls on its own.

## Configuring static serving

If we are to serve locally saved files, we need to configure
[`Plug.Static`](https://hexdocs.pm/plug/Plug.Static.html) plug.

```elixir
defmodule MyAppWeb.Endpoind do
  # ...

  plug Plug.Static,
    at: "/uploads",
    from: "./uploads"

  # ...
end
```

> #### Note {: .info}
>
> For S3 storage you don't need to serve static files as links point
> to the bucket, not to your application.
