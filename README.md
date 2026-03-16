# TailwindCombine

[![CI](https://github.com/levibuzolic/tailwind_combine/actions/workflows/ci.yml/badge.svg)](https://github.com/levibuzolic/tailwind_combine/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/tailwind_combine.svg)](https://hex.pm/packages/tailwind_combine)

Merge Tailwind CSS classes in Elixir without style conflicts.

> Inspired by the upstream JS package, [`tailwind-merge`](https://www.npmjs.com/package/tailwind-merge).

## Why?

Overriding Tailwind CSS classes is unintuitive.

Due to the way the [CSS Cascade](https://developer.mozilla.org/en-US/docs/Web/CSS/Cascade) works, the order of CSS styles applied on an element isn't based on the order of given classes, but the order in which CSS styles appear in CSS stylesheets. Because of that, when using Tailwind CSS classes which involve the same styles (we call them _conflicting classes_), the final styles are indeterminate.

```heex
<% # Is it red or green? It's hard to say. %>
<div class={["h-12 bg-red-500", "bg-green-500"]}></div>
```

`TailwindCombine` solves this problem by overriding _conflicting classes_ and keeping everything else untouched.

```heex
<div class={TailwindCombine.merge(["h-12 bg-red-500", "bg-green-500"])}></div>
<% # equals to %>
<div class="h-12 bg-green-500"></div>
```

## Status

- Supports Tailwind CSS v4 merge semantics, with coverage centered on the same core behavior tested by [`tailwind-merge`](https://www.npmjs.com/package/tailwind-merge).
- Tracks the upstream JS implementation with a growing parity test suite.
- Preserves the Elixir package's existing config model via `use TailwindCombine` and `TailwindCombine.Config.new/1`.

## Installation

Add `:tailwind_combine` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tailwind_combine, <requirement>}
  ]
end
```

Release instructions live in [RELEASING.md](./RELEASING.md).

## Usage

Use the default config directly:

```elixir
TailwindCombine.merge("p-2 p-4")
# "p-4"

TailwindCombine.merge(["p-2", nil, ["hover:p-2", "hover:p-4"]])
# "p-2 hover:p-4"
```

This is usually enough for Phoenix components and HEEx templates:

```heex
<button class={TailwindCombine.merge(["px-3 py-2", @class, @active && "bg-blue-600"])}>
  Save
</button>
```

## Helper Module

If you want a shorter local helper, define one in your application:

```elixir
defmodule DemoWeb.ClassHelper do
  use TailwindCombine
end
```

That gives you `DemoWeb.ClassHelper.tw/1`:

```elixir
DemoWeb.ClassHelper.tw("text-sm text-lg")
# "text-lg"
```

## Custom Config

You can keep the default config shape and override parts of it:

```elixir
defmodule DemoWeb.ClassHelper do
  colors = TailwindCombine.Config.colors() ++ ["primary", "secondary"]
  class_groups = TailwindCombine.Config.class_groups(colors: colors)

  use TailwindCombine,
    as: :merge_class,
    config: TailwindCombine.Config.new(class_groups: class_groups)
end

DemoWeb.ClassHelper.merge_class("text-red-500 text-primary")
# "text-primary"
```

Prefix support is also available:

```elixir
defmodule DemoWeb.Tw do
  use TailwindCombine,
    config: TailwindCombine.Config.new(prefix: "tw")
end

DemoWeb.Tw.tw("tw:p-2 tw:p-4")
# "tw:p-4"
```

## Notes

- Unknown classes pass through unchanged.
- Nested class lists, `nil`, and `false` values are ignored in list input.
- The library focuses on merge behavior parity with the upstream JS package, [`tailwind-merge`](https://www.npmjs.com/package/tailwind-merge); JS-specific factory APIs are not part of the Elixir public API.

For more detail, see the [documentation](https://hexdocs.pm/tailwind_combine).

## Similar projects

- [bratsche/twix](https://github.com/bratsche/twix)
- [zachdaniel/tails](https://github.com/zachdaniel/tails)

## License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0) / [MIT](./License)
