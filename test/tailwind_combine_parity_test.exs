# credo:disable-for-this-file
defmodule TailwindCombineParityTest do
  @moduledoc """
  Behavioral parity checks ported from the upstream JS test suite.

    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/conflicts-across-class-groups.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/non-tailwind-classes.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/arbitrary-properties.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/arbitrary-variants.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/important-modifier.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/modifiers.test.ts

  """

  use ExUnit.Case
  import TailwindHelper

  test "handles conflicts across class groups correctly" do
    assert tw("inset-1 inset-x-1") == "inset-1 inset-x-1"
    assert tw("inset-x-1 inset-1") == "inset-1"
    assert tw("inset-x-1 left-1 inset-1") == "inset-1"
    assert tw("inset-x-1 inset-1 left-1") == "inset-1 left-1"
    assert tw("inset-x-1 right-1 inset-1") == "inset-1"
    assert tw("inset-x-1 right-1 inset-x-1") == "inset-x-1"
    assert tw("inset-x-1 right-1 inset-y-1") == "inset-x-1 right-1 inset-y-1"
    assert tw("right-1 inset-x-1 inset-y-1") == "inset-x-1 inset-y-1"
    assert tw("inset-x-1 hover:left-1 inset-1") == "hover:left-1 inset-1"
  end

  test "keeps ring and shadow classes independent" do
    assert tw("ring shadow") == "ring shadow"
    assert tw("ring-2 shadow-md") == "ring-2 shadow-md"
    assert tw("shadow ring") == "shadow ring"
    assert tw("shadow-md ring-2") == "shadow-md ring-2"
  end

  test "does not alter non-tailwind classes" do
    assert tw("non-tailwind-class inline block") == "non-tailwind-class block"
    assert tw("inline block inline-1") == "block inline-1"
    assert tw("inline block i-inline") == "block i-inline"
    assert tw("focus:inline focus:block focus:inline-1") == "focus:block focus:inline-1"
  end

  test "handles arbitrary property conflicts correctly" do
    assert tw("[paint-order:markers] [paint-order:normal]") == "[paint-order:normal]"

    assert tw("[paint-order:markers] [--my-var:2rem] [paint-order:normal] [--my-var:4px]") ==
             "[paint-order:normal] [--my-var:4px]"

    assert tw("[paint-order:markers] hover:[paint-order:normal]") ==
             "[paint-order:markers] hover:[paint-order:normal]"

    assert tw("hover:[paint-order:markers] hover:[paint-order:normal]") ==
             "hover:[paint-order:normal]"

    assert tw("hover:focus:[paint-order:markers] focus:hover:[paint-order:normal]") ==
             "focus:hover:[paint-order:normal]"

    assert tw("[paint-order:markers] [paint-order:normal] [--my-var:2rem] lg:[--my-var:4px]") ==
             "[paint-order:normal] [--my-var:2rem] lg:[--my-var:4px]"

    assert tw("[-unknown-prop:::123:::] [-unknown-prop:url(https://hi.com)]") ==
             "[-unknown-prop:url(https://hi.com)]"
  end

  test "handles arbitrary variants correctly" do
    assert tw("[p]:underline [p]:line-through") == "[p]:line-through"
    assert tw("[&>*]:underline [&>*]:line-through") == "[&>*]:line-through"

    assert tw("[&>*]:underline [&>*]:line-through [&_div]:line-through") ==
             "[&>*]:line-through [&_div]:line-through"

    assert tw("supports-[display:grid]:flex supports-[display:grid]:grid") ==
             "supports-[display:grid]:grid"

    assert tw("dark:lg:hover:[&>*]:underline dark:lg:hover:[&>*]:line-through") ==
             "dark:lg:hover:[&>*]:line-through"

    assert tw("dark:lg:hover:[&>*]:underline dark:hover:lg:[&>*]:line-through") ==
             "dark:hover:lg:[&>*]:line-through"

    assert tw("hover:[&>*]:underline [&>*]:hover:line-through") ==
             "hover:[&>*]:underline [&>*]:hover:line-through"

    assert tw(
             "hover:dark:[&>*]:underline dark:hover:[&>*]:underline dark:[&>*]:hover:line-through"
           ) ==
             "dark:hover:[&>*]:underline dark:[&>*]:hover:line-through"

    assert tw(
             "[@media_screen{@media(hover:hover)}]:underline [@media_screen{@media(hover:hover)}]:line-through"
           ) ==
             "[@media_screen{@media(hover:hover)}]:line-through"

    assert tw(
             "hover:[@media_screen{@media(hover:hover)}]:underline hover:[@media_screen{@media(hover:hover)}]:line-through"
           ) ==
             "hover:[@media_screen{@media(hover:hover)}]:line-through"

    assert tw("[&[data-open]]:underline [&[data-open]]:line-through") ==
             "[&[data-open]]:line-through"

    assert tw(
             "[&[data-foo][data-bar]:not([data-baz])]:underline [&[data-foo][data-bar]:not([data-baz])]:line-through"
           ) ==
             "[&[data-foo][data-bar]:not([data-baz])]:line-through"

    assert tw("[&>*]:[&_div]:underline [&>*]:[&_div]:line-through") ==
             "[&>*]:[&_div]:line-through"

    assert tw("[&>*]:[&_div]:underline [&_div]:[&>*]:line-through") ==
             "[&>*]:[&_div]:underline [&_div]:[&>*]:line-through"

    assert tw(
             "hover:dark:[&>*]:focus:disabled:[&_div]:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through"
           ) ==
             "dark:hover:[&>*]:disabled:focus:[&_div]:line-through"

    assert tw(
             "hover:dark:[&>*]:focus:[&_div]:disabled:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through"
           ) ==
             "hover:dark:[&>*]:focus:[&_div]:disabled:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through"

    assert tw("[&>*]:[color:red] [&>*]:[color:blue]") == "[&>*]:[color:blue]"

    assert tw(
             "[&[data-foo][data-bar]:not([data-baz])]:nod:noa:[color:red] [&[data-foo][data-bar]:not([data-baz])]:noa:nod:[color:blue]"
           ) ==
             "[&[data-foo][data-bar]:not([data-baz])]:noa:nod:[color:blue]"
  end

  test "handles important modifier correctly" do
    assert tw("font-medium! font-bold!") == "font-bold!"
    assert tw("font-medium! font-bold! font-thin") == "font-bold! font-thin"
    assert tw("right-2! -inset-x-px!") == "-inset-x-px!"
    assert tw("focus:inline! focus:block!") == "focus:block!"
    assert tw("[--my-var:20px]! [--my-var:30px]!") == "[--my-var:30px]!"
    assert tw("font-medium! !font-bold") == "!font-bold"
    assert tw("!font-medium !font-bold") == "!font-bold"
    assert tw("!font-medium !font-bold font-thin") == "!font-bold font-thin"
    assert tw("!right-2 !-inset-x-px") == "!-inset-x-px"
    assert tw("focus:!inline focus:!block") == "focus:!block"
    assert tw("![--my-var:20px] ![--my-var:30px]") == "![--my-var:30px]"
  end

  test "handles modifier sorting and postfix conflicts correctly" do
    assert tw("hover:block hover:inline") == "hover:inline"
    assert tw("hover:block hover:focus:inline") == "hover:block hover:focus:inline"

    assert tw("hover:block hover:focus:inline focus:hover:inline") ==
             "hover:block focus:hover:inline"

    assert tw("text-lg/7 text-lg/8") == "text-lg/8"
    assert tw("text-lg/none leading-9") == "text-lg/none leading-9"
    assert tw("leading-9 text-lg/none") == "text-lg/none"
    assert tw("w-full w-1/2") == "w-1/2"
    assert tw("c:d:e:block d:c:e:inline") == "d:c:e:inline"
    assert tw("*:before:block *:before:inline") == "*:before:inline"
    assert tw("*:before:block before:*:inline") == "*:before:block before:*:inline"
    assert tw("x:y:*:z:block y:x:*:z:inline") == "y:x:*:z:inline"
  end
end
