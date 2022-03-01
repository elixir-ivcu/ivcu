# Image Validator, Converter, and Uploader

A library to validate, convert, and upload images.

## Why another library?

This library serves as a replacement for
[waffle](https://github.com/elixir-waffle/waffle) which leaves a lot
to be desired.

1. Waffle abuses `__using__` macro where it could use behaviours with
   defined interfaces.

2. It has too much levels of indirection where it doesn't need to
   (nested usings for example), making it harder to understend the
   codebase.

3. The lack or incorrectness of documentation only makes things worse.

Still this library mainly uses the same concepts as its predecessor,
it just attempts to implement them differently.

## ivcu_ecto when?

There is a package named
[waffle_ecto](https://github.com/elixir-waffle/waffle_ecto) that
attempts to integrate waffle into ecto changesets, which is a bad
decision as changesets are supposed to be pure computations without
side-effects. When we add effects to them, we only catch strange
behaviour.

As an example, when we call `Ecto.Changeset.apply_action/2` to do
validations, we trigger storing action saving corresponding file when
we only needed to cast and validate params.

Also, with `waffle_ecto` we tie the process, of saving an image, to a
database action and yet don't handle image deletion on an update.

Your best bet is to manage the storing
[manually](./guides/using_with_ecto.md).

## Installation and Usage

See [Getting Started](./guides/getting_started.md) guide.

## Documentation

Documentation can be found at
[https://hexdocs.pm/ivcu](https://hexdocs.pm/ivcu).
