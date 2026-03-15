# credo:disable-for-this-file
defmodule TailwindCombineArbitraryValuesTest do
  @moduledoc """
  Additional upstream parity checks for arbitrary values and related utilities.

    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/arbitrary-values.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/colors.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/content-utilities.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/pseudo-variants.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/negative-values.test.ts

  """

  use ExUnit.Case
  import TailwindHelper

  test "handles arbitrary value conflicts correctly" do
    assert tw("m-[2px] m-[10px]") == "m-[10px]"

    assert tw(
             "m-[2px] m-[11svmin] m-[12in] m-[13lvi] m-[14vb] m-[15vmax] m-[16mm] m-[17%] m-[18em] m-[19px] m-[10dvh]"
           ) == "m-[10dvh]"

    assert tw("h-[10px] h-[11cqw] h-[12cqh] h-[13cqi] h-[14cqb] h-[15cqmin] h-[16cqmax]") ==
             "h-[16cqmax]"

    assert tw("z-20 z-[99]") == "z-[99]"
    assert tw("my-[2px] m-[10rem]") == "m-[10rem]"
    assert tw("cursor-pointer cursor-[grab]") == "cursor-[grab]"
    assert tw("m-[2px] m-[calc(100%-var(--arbitrary))]") == "m-[calc(100%-var(--arbitrary))]"
    assert tw("m-[2px] m-[length:var(--mystery-var)]") == "m-[length:var(--mystery-var)]"
    assert tw("opacity-10 opacity-[0.025]") == "opacity-[0.025]"
    assert tw("scale-75 scale-[1.7]") == "scale-[1.7]"
    assert tw("brightness-90 brightness-[1.75]") == "brightness-[1.75]"
    assert tw("min-h-[0.5px] min-h-[0]") == "min-h-[0]"
    assert tw("text-[0.5px] text-[color:0]") == "text-[0.5px] text-[color:0]"
    assert tw("text-[0.5px] text-(--my-0)") == "text-[0.5px] text-(--my-0)"
  end

  test "handles ambiguous arbitrary values and custom properties correctly" do
    assert tw("hover:m-[2px] hover:m-[length:var(--c)]") == "hover:m-[length:var(--c)]"

    assert tw("hover:focus:m-[2px] focus:hover:m-[length:var(--c)]") ==
             "focus:hover:m-[length:var(--c)]"

    assert tw("border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))]") ==
             "border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))]"

    assert tw("border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-b") ==
             "border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-b"

    assert tw("border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-some-coloooor") ==
             "border-b border-some-coloooor"

    assert tw("grid-rows-[1fr,auto] grid-rows-2") == "grid-rows-2"
    assert tw("grid-rows-[repeat(20,minmax(0,1fr))] grid-rows-3") == "grid-rows-3"

    assert tw("mt-2 mt-[calc(theme(fontSize.4xl)/1.125)]") ==
             "mt-[calc(theme(fontSize.4xl)/1.125)]"

    assert tw("p-2 p-[calc(theme(fontSize.4xl)/1.125)_10px]") ==
             "p-[calc(theme(fontSize.4xl)/1.125)_10px]"

    assert tw("mt-2 mt-[length:theme(someScale.someValue)]") ==
             "mt-[length:theme(someScale.someValue)]"

    assert tw("mt-2 mt-[theme(someScale.someValue)]") == "mt-[theme(someScale.someValue)]"

    assert tw("text-2xl text-[length:theme(someScale.someValue)]") ==
             "text-[length:theme(someScale.someValue)]"

    assert tw("text-2xl text-[calc(theme(fontSize.4xl)/1.125)]") ==
             "text-[calc(theme(fontSize.4xl)/1.125)]"

    assert tw("bg-cover bg-[percentage:30%] bg-[size:200px_100px] bg-[length:200px_100px]") ==
             "bg-[percentage:30%] bg-[length:200px_100px]"

    assert tw(
             "bg-none bg-[url(.)] bg-[image:.] bg-[url:.] bg-[linear-gradient(.)] bg-linear-to-r"
           ) ==
             "bg-linear-to-r"

    assert tw("border-[color-mix(in_oklab,var(--background),var(--calendar-color)_30%)] border") ==
             "border-[color-mix(in_oklab,var(--background),var(--calendar-color)_30%)] border"

    assert tw("font-[400] font-[600]") == "font-[600]"
    assert tw("font-[var(--a)] font-[var(--b)]") == "font-[var(--b)]"
    assert tw("font-[weight:var(--a)] font-[var(--b)]") == "font-[var(--b)]"
    assert tw("font-[400] font-[weight:var(--b)]") == "font-[weight:var(--b)]"
    assert tw("font-[weight:var(--a)] font-[weight:var(--b)]") == "font-[weight:var(--b)]"

    assert tw("font-[family-name:var(--a)] font-[var(--b)]") ==
             "font-[family-name:var(--a)] font-[var(--b)]"

    assert tw("bg-red bg-(--other-red) bg-bottom bg-(position:-my-pos)") ==
             "bg-(--other-red) bg-(position:-my-pos)"

    assert tw(
             "shadow-xs shadow-(shadow:--something) shadow-red shadow-(--some-other-shadow) shadow-(color:--some-color)"
           ) ==
             "shadow-(--some-other-shadow) shadow-(color:--some-color)"

    assert tw("font-(--a) font-(--b)") == "font-(--b)"
    assert tw("font-(weight:--a) font-(--b)") == "font-(--b)"
    assert tw("font-(family-name:--a) font-(--b)") == "font-(family-name:--a) font-(--b)"
  end

  test "handles colors, content utilities, pseudo variants, and negative values" do
    assert tw("bg-grey-5 bg-hotpink") == "bg-hotpink"
    assert tw("hover:bg-grey-5 hover:bg-hotpink") == "hover:bg-hotpink"

    assert tw("stroke-[hsl(350_80%_0%)] stroke-[10px]") ==
             "stroke-[hsl(350_80%_0%)] stroke-[10px]"

    assert tw("content-['hello'] content-[attr(data-content)]") == "content-[attr(data-content)]"
    assert tw("empty:p-2 empty:p-3") == "empty:p-3"
    assert tw("hover:empty:p-2 hover:empty:p-3") == "hover:empty:p-3"
    assert tw("read-only:p-2 read-only:p-3") == "read-only:p-3"
    assert tw("group-empty:p-2 group-empty:p-3") == "group-empty:p-3"
    assert tw("peer-empty:p-2 peer-empty:p-3") == "peer-empty:p-3"
    assert tw("group-empty:p-2 peer-empty:p-3") == "group-empty:p-2 peer-empty:p-3"
    assert tw("hover:group-empty:p-2 hover:group-empty:p-3") == "hover:group-empty:p-3"
    assert tw("group-read-only:p-2 group-read-only:p-3") == "group-read-only:p-3"
    assert tw("-m-2 -m-5") == "-m-5"
    assert tw("-top-12 -top-2000") == "-top-2000"
    assert tw("-m-2 m-auto") == "m-auto"
    assert tw("top-12 -top-69") == "-top-69"
    assert tw("-right-1 inset-x-1") == "inset-x-1"
    assert tw("hover:focus:-right-1 focus:hover:inset-x-1") == "focus:hover:inset-x-1"
  end
end
