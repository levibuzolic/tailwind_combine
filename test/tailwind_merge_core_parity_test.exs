# credo:disable-for-this-file
defmodule TailwindMergeCoreParityTest do
  @moduledoc """
  Remaining core upstream behavior coverage.

    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/class-group-conflicts.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/tw-merge.test.ts
    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/prefixes.test.ts

  """

  use ExUnit.Case
  import TailwindHelper

  test "merges classes from same group correctly" do
    assert tw("overflow-x-auto overflow-x-hidden") == "overflow-x-hidden"
    assert tw("basis-full basis-auto") == "basis-auto"
    assert tw("w-full w-fit") == "w-fit"
    assert tw("overflow-x-auto overflow-x-hidden overflow-x-scroll") == "overflow-x-scroll"

    assert tw("overflow-x-auto hover:overflow-x-hidden overflow-x-scroll") ==
             "hover:overflow-x-hidden overflow-x-scroll"

    assert tw("overflow-x-auto hover:overflow-x-hidden hover:overflow-x-auto overflow-x-scroll") ==
             "hover:overflow-x-auto overflow-x-scroll"

    assert tw("col-span-1 col-span-full") == "col-span-full"
    assert tw("gap-2 gap-px basis-px basis-3") == "gap-px basis-3"
  end

  test "merges classes from font variant numeric section correctly" do
    assert tw("lining-nums tabular-nums diagonal-fractions") ==
             "lining-nums tabular-nums diagonal-fractions"

    assert tw("normal-nums tabular-nums diagonal-fractions") ==
             "tabular-nums diagonal-fractions"

    assert tw("tabular-nums diagonal-fractions normal-nums") == "normal-nums"
    assert tw("tabular-nums proportional-nums") == "proportional-nums"
  end

  test "matches upstream general merge cases" do
    assert tw("mix-blend-normal mix-blend-multiply") == "mix-blend-multiply"
    assert tw("h-10 h-min") == "h-min"
    assert tw("stroke-black stroke-1") == "stroke-black stroke-1"
    assert tw("stroke-2 stroke-[3]") == "stroke-[3]"
    assert tw("outline-black outline-1") == "outline-black outline-1"
    assert tw("grayscale-0 grayscale-[50%]") == "grayscale-[50%]"
    assert tw("grow grow-[2]") == "grow-[2]"
    assert tw(["grow", nil, false, [["grow-[2]"]]]) == "grow-[2]"
  end
end

defmodule TailwindMergePrefixParityTest do
  @moduledoc false

  use ExUnit.Case
  import TailwindPrefixedHelper

  test "prefix works correctly" do
    assert tw("tw:block tw:hidden") == "tw:hidden"
    assert tw("block hidden") == "block hidden"
    assert tw("tw:p-3 tw:p-2") == "tw:p-2"
    assert tw("p-3 p-2") == "p-3 p-2"
    assert tw("tw:right-0! tw:inset-0!") == "tw:inset-0!"
    assert tw("tw:hover:focus:right-0! tw:focus:hover:inset-0!") == "tw:focus:hover:inset-0!"
  end
end
