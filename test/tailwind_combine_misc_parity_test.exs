# credo:disable-for-this-file
defmodule TailwindCombineMiscParityTest do
  @moduledoc """
  Smaller upstream parity checks for standalone classes, non-conflicting cases,
  per-side border colors, and whitespace normalization.

    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/standalone-classes.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/non-conflicting-classes.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/per-side-border-colors.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/wonky-inputs.test.ts

  """

  use ExUnit.Case
  import TailwindHelper

  test "handles standalone and non-conflicting classes correctly" do
    assert tw("inline block") == "block"
    assert tw("hover:block hover:inline") == "hover:inline"
    assert tw("hover:block hover:block") == "hover:block"

    assert tw("inline hover:inline focus:inline hover:block hover:focus:block") ==
             "inline focus:inline hover:block hover:focus:block"

    assert tw("underline line-through") == "line-through"
    assert tw("line-through no-underline") == "no-underline"
    assert tw("border-t border-white/10") == "border-t border-white/10"
    assert tw("border-t border-white") == "border-t border-white"
    assert tw("text-3.5xl text-black") == "text-3.5xl text-black"
  end

  test "handles per-side border colors correctly" do
    assert tw("border-t-some-blue border-t-other-blue") == "border-t-other-blue"
    assert tw("border-t-some-blue border-some-blue") == "border-some-blue"
    assert tw("border-some-blue border-s-some-blue") == "border-some-blue border-s-some-blue"
    assert tw("border-e-some-blue border-some-blue") == "border-some-blue"
  end

  test "normalizes wonky input whitespace" do
    assert tw(" block") == "block"
    assert tw("block ") == "block"
    assert tw(" block ") == "block"
    assert tw("  block  px-2     py-4  ") == "block px-2 py-4"
    assert tw("block\npx-2") == "block px-2"
    assert tw("\nblock\npx-2\n") == "block px-2"
    assert tw("  block\n        \n        px-2   \n          py-4  ") == "block px-2 py-4"
    assert tw("\r  block\n\r        \n        px-2   \n          py-4  ") == "block px-2 py-4"
  end
end
