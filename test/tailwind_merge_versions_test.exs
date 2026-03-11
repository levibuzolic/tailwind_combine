# credo:disable-for-this-file
defmodule TailwindMergeVersionsTest do
  @moduledoc """
  Port of upstream `tailwind-css-versions.test.ts`.

    * https://github.com/dcastil/tailwind-merge/blob/ef91df55ea3be957e222aaa5963d0cac8b69d380/tests/tailwind-css-versions.test.ts

  """

  use ExUnit.Case
  import TailwindHelper

  test "supports Tailwind CSS v3.3 features" do
    assert tw("text-red text-lg/7 text-lg/8") == "text-red text-lg/8"

    assert tw(
             "start-0 start-1 end-0 end-1 ps-0 ps-1 pe-0 pe-1 ms-0 ms-1 me-0 me-1 rounded-s-sm rounded-s-md rounded-e-sm rounded-e-md rounded-ss-sm rounded-ss-md rounded-ee-sm rounded-ee-md"
           ) ==
             "start-1 end-1 ps-1 pe-1 ms-1 me-1 rounded-s-md rounded-e-md rounded-ss-md rounded-ee-md"

    assert tw("start-0 end-0 inset-0 ps-0 pe-0 p-0 ms-0 me-0 m-0 rounded-ss rounded-es rounded-s") ==
             "inset-0 p-0 m-0 rounded-s"

    assert tw("hyphens-auto hyphens-manual") == "hyphens-manual"

    assert tw("from-0% from-10% from-[12.5%] via-0% via-10% via-[12.5%] to-0% to-10% to-[12.5%]") ==
             "from-[12.5%] via-[12.5%] to-[12.5%]"

    assert tw("from-0% from-red") == "from-0% from-red"

    assert tw("list-image-none list-image-[url(./my-image.png)] list-image-[var(--value)]") ==
             "list-image-[var(--value)]"

    assert tw("caption-top caption-bottom") == "caption-bottom"
    assert tw("line-clamp-2 line-clamp-none line-clamp-[10]") == "line-clamp-[10]"
    assert tw("delay-150 delay-0 duration-150 duration-0") == "delay-0 duration-0"
    assert tw("justify-normal justify-center justify-stretch") == "justify-stretch"
    assert tw("content-normal content-center content-stretch") == "content-stretch"
    assert tw("whitespace-nowrap whitespace-break-spaces") == "whitespace-break-spaces"
  end

  test "supports Tailwind CSS v3.4 features" do
    assert tw("h-svh h-dvh w-svw w-dvw") == "h-dvh w-dvw"

    assert tw(
             "has-[[data-potato]]:p-1 has-[[data-potato]]:p-2 group-has-[:checked]:grid group-has-[:checked]:flex"
           ) ==
             "has-[[data-potato]]:p-2 group-has-[:checked]:flex"

    assert tw("text-wrap text-pretty") == "text-pretty"
    assert tw("w-5 h-3 size-10 w-12") == "size-10 w-12"

    assert tw("grid-cols-2 grid-cols-subgrid grid-rows-5 grid-rows-subgrid") ==
             "grid-cols-subgrid grid-rows-subgrid"

    assert tw("min-w-0 min-w-50 min-w-px max-w-0 max-w-50 max-w-px") == "min-w-px max-w-px"
    assert tw("forced-color-adjust-none forced-color-adjust-auto") == "forced-color-adjust-auto"
    assert tw("appearance-none appearance-auto") == "appearance-auto"
    assert tw("float-start float-end clear-start clear-end") == "float-end clear-end"
    assert tw("*:p-10 *:p-20 hover:*:p-10 hover:*:p-20") == "*:p-20 hover:*:p-20"
  end

  test "supports Tailwind CSS v4.0 features" do
    assert tw("transform-3d transform-flat") == "transform-flat"

    assert tw("rotate-12 rotate-x-2 rotate-none rotate-y-3") ==
             "rotate-x-2 rotate-none rotate-y-3"

    assert tw("perspective-dramatic perspective-none perspective-midrange") ==
             "perspective-midrange"

    assert tw("perspective-origin-center perspective-origin-top-left") ==
             "perspective-origin-top-left"

    assert tw("bg-linear-to-r bg-linear-45") == "bg-linear-45"
    assert tw("bg-linear-to-r bg-radial-[something] bg-conic-10") == "bg-conic-10"

    assert tw("ring-4 ring-orange inset-ring inset-ring-3 inset-ring-blue") ==
             "ring-4 ring-orange inset-ring-3 inset-ring-blue"

    assert tw("field-sizing-content field-sizing-fixed") == "field-sizing-fixed"
    assert tw("scheme-normal scheme-dark") == "scheme-dark"

    assert tw("font-stretch-expanded font-stretch-[66.66%] font-stretch-50%") ==
             "font-stretch-50%"

    assert tw("col-span-full col-2 row-span-3 row-4") == "col-2 row-4"
    assert tw("via-red-500 via-(--mobile-header-gradient)") == "via-(--mobile-header-gradient)"

    assert tw("via-red-500 via-(length:--mobile-header-gradient)") ==
             "via-red-500 via-(length:--mobile-header-gradient)"
  end

  test "supports Tailwind CSS v4.1 features" do
    assert tw("items-baseline items-baseline-last") == "items-baseline-last"
    assert tw("self-baseline self-baseline-last") == "self-baseline-last"

    assert tw("place-content-center place-content-end-safe place-content-center-safe") ==
             "place-content-center-safe"

    assert tw("items-center-safe items-baseline items-end-safe") == "items-end-safe"
    assert tw("wrap-break-word wrap-normal wrap-anywhere") == "wrap-anywhere"
    assert tw("text-shadow-none text-shadow-2xl") == "text-shadow-2xl"

    assert tw(
             "text-shadow-none text-shadow-md text-shadow-red text-shadow-red-500 shadow-red shadow-3xs"
           ) == "text-shadow-md text-shadow-red-500 shadow-red shadow-3xs"

    assert tw("mask-add mask-subtract") == "mask-subtract"

    assert tw(
             "mask-(--foo) mask-[foo] mask-none mask-linear-1 mask-linear-2 mask-linear-from-[position:test] mask-linear-from-3 mask-linear-to-[position:test] mask-linear-to-3 mask-linear-from-color-red mask-linear-from-color-3 mask-linear-to-color-red mask-linear-to-color-3 mask-t-from-[position:test] mask-t-from-3 mask-t-to-[position:test] mask-t-to-3 mask-t-from-color-red mask-t-from-color-3 mask-radial-(--test) mask-radial-[test] mask-radial-from-[position:test] mask-radial-from-3 mask-radial-to-[position:test] mask-radial-to-3 mask-radial-from-color-red mask-radial-from-color-3"
           ) ==
             "mask-none mask-linear-2 mask-linear-from-3 mask-linear-to-3 mask-linear-from-color-3 mask-linear-to-color-3 mask-t-from-3 mask-t-to-3 mask-t-from-color-3 mask-radial-[test] mask-radial-from-3 mask-radial-to-3 mask-radial-from-color-3"

    assert tw(
             "mask-(--something) mask-[something] mask-top-left mask-center mask-(position:--var) mask-[position:1px_1px] mask-position-(--var) mask-position-[1px_1px]"
           ) ==
             "mask-[something] mask-position-[1px_1px]"

    assert tw(
             "mask-(--something) mask-[something] mask-auto mask-[size:foo] mask-(size:--foo) mask-size-[foo] mask-size-(--foo) mask-cover mask-contain"
           ) ==
             "mask-[something] mask-contain"

    assert tw("mask-type-luminance mask-type-alpha") == "mask-type-alpha"

    assert tw("shadow-md shadow-lg/25 text-shadow-md text-shadow-lg/25") ==
             "shadow-lg/25 text-shadow-lg/25"

    assert tw("drop-shadow-some-color drop-shadow-[#123456] drop-shadow-lg drop-shadow-[10px_0]") ==
             "drop-shadow-[#123456] drop-shadow-[10px_0]"

    assert tw("drop-shadow-[#123456] drop-shadow-some-color") == "drop-shadow-some-color"
    assert tw("drop-shadow-2xl drop-shadow-[shadow:foo]") == "drop-shadow-[shadow:foo]"
  end

  test "supports Tailwind CSS v4.1.5 features" do
    assert tw("h-12 h-lh") == "h-lh"
    assert tw("min-h-12 min-h-lh") == "min-h-lh"
    assert tw("max-h-12 max-h-lh") == "max-h-lh"
  end

  test "supports Tailwind CSS v4.2 features" do
    assert tw("inset-s-1 inset-s-2") == "inset-s-2"
    assert tw("inset-e-1 inset-e-2") == "inset-e-2"
    assert tw("inset-bs-1 inset-bs-2") == "inset-bs-2"
    assert tw("inset-be-1 inset-be-2") == "inset-be-2"
    assert tw("start-1 inset-s-2") == "inset-s-2"
    assert tw("inset-s-1 start-2") == "start-2"
    assert tw("end-1 inset-e-2") == "inset-e-2"
    assert tw("inset-e-1 end-2") == "end-2"
    assert tw("inset-s-1 inset-e-2 inset-bs-3 inset-be-4 inset-0") == "inset-0"
    assert tw("inset-0 inset-s-1 inset-bs-1") == "inset-0 inset-s-1 inset-bs-1"
    assert tw("inset-y-1 inset-bs-2 inset-be-3") == "inset-y-1 inset-bs-2 inset-be-3"
    assert tw("top-1 inset-bs-2 bottom-3 inset-be-4") == "top-1 inset-bs-2 bottom-3 inset-be-4"
    assert tw("pbs-1 pbs-2") == "pbs-2"
    assert tw("pbe-1 pbe-2") == "pbe-2"
    assert tw("mbs-1 mbs-2") == "mbs-2"
    assert tw("mbe-1 mbe-2") == "mbe-2"
    assert tw("pt-1 pbs-2") == "pt-1 pbs-2"
    assert tw("pb-1 pbe-2") == "pb-1 pbe-2"
    assert tw("mt-1 mbs-2") == "mt-1 mbs-2"
    assert tw("mb-1 mbe-2") == "mb-1 mbe-2"
    assert tw("p-0 pbs-1 pbe-1") == "p-0 pbs-1 pbe-1"
    assert tw("pbs-1 pbe-1 p-0") == "p-0"
    assert tw("m-0 mbs-1 mbe-1") == "m-0 mbs-1 mbe-1"
    assert tw("mbs-1 mbe-1 m-0") == "m-0"
    assert tw("py-1 pbs-2 pbe-3") == "py-1 pbs-2 pbe-3"
    assert tw("my-1 mbs-2 mbe-3") == "my-1 mbs-2 mbe-3"
    assert tw("scroll-pbs-1 scroll-pbs-2") == "scroll-pbs-2"
    assert tw("scroll-pbe-1 scroll-pbe-2") == "scroll-pbe-2"
    assert tw("scroll-mbs-1 scroll-mbs-2") == "scroll-mbs-2"
    assert tw("scroll-mbe-1 scroll-mbe-2") == "scroll-mbe-2"
    assert tw("scroll-pt-1 scroll-pbs-2") == "scroll-pt-1 scroll-pbs-2"
    assert tw("scroll-pb-1 scroll-pbe-2") == "scroll-pb-1 scroll-pbe-2"
    assert tw("scroll-mt-1 scroll-mbs-2") == "scroll-mt-1 scroll-mbs-2"
    assert tw("scroll-mb-1 scroll-mbe-2") == "scroll-mb-1 scroll-mbe-2"
    assert tw("scroll-p-0 scroll-pbs-1 scroll-pbe-1") == "scroll-p-0 scroll-pbs-1 scroll-pbe-1"
    assert tw("scroll-pbs-1 scroll-pbe-1 scroll-p-0") == "scroll-p-0"
    assert tw("scroll-m-0 scroll-mbs-1 scroll-mbe-1") == "scroll-m-0 scroll-mbs-1 scroll-mbe-1"
    assert tw("scroll-mbs-1 scroll-mbe-1 scroll-m-0") == "scroll-m-0"
    assert tw("scroll-py-1 scroll-pbs-2 scroll-pbe-3") == "scroll-py-1 scroll-pbs-2 scroll-pbe-3"
    assert tw("scroll-my-1 scroll-mbs-2 scroll-mbe-3") == "scroll-my-1 scroll-mbs-2 scroll-mbe-3"
    assert tw("border-bs-1 border-bs-2") == "border-bs-2"
    assert tw("border-be-1 border-be-2") == "border-be-2"
    assert tw("border-bs-red border-bs-blue") == "border-bs-blue"
    assert tw("border-be-red border-be-blue") == "border-be-blue"
    assert tw("border-2 border-bs-4 border-be-6") == "border-2 border-bs-4 border-be-6"
    assert tw("border-bs-4 border-be-6 border-2") == "border-2"

    assert tw("border-red border-bs-blue border-be-green") ==
             "border-red border-bs-blue border-be-green"

    assert tw("border-bs-blue border-be-green border-red") == "border-red"
    assert tw("border-y-2 border-bs-4 border-be-6") == "border-y-2 border-bs-4 border-be-6"

    assert tw("border-t-2 border-bs-4 border-b-6 border-be-8") ==
             "border-t-2 border-bs-4 border-b-6 border-be-8"

    assert tw("border-y-red border-bs-blue border-be-green") ==
             "border-y-red border-bs-blue border-be-green"

    assert tw("inline-1/2 inline-3/4") == "inline-3/4"
    assert tw("block-1/2 block-3/4") == "block-3/4"
    assert tw("min-inline-auto min-inline-full") == "min-inline-full"
    assert tw("max-inline-none max-inline-10") == "max-inline-10"
    assert tw("min-block-auto min-block-lh min-block-10") == "min-block-10"
    assert tw("max-block-none max-block-lh max-block-10") == "max-block-10"
    assert tw("w-10 inline-20") == "w-10 inline-20"
    assert tw("h-10 block-20") == "h-10 block-20"
    assert tw("size-10 inline-20 block-30") == "size-10 inline-20 block-30"
    assert tw("min-w-10 min-inline-20") == "min-w-10 min-inline-20"
    assert tw("max-h-10 max-block-20") == "max-h-10 max-block-20"
    assert tw(~s|font-features-["smcp"] font-features-["onum"]|) == ~s|font-features-["onum"]|

    assert tw(~s|font-features-[var(--font-features)] font-features-["liga","dlig"]|) ==
             ~s|font-features-["liga","dlig"]|

    assert tw(~s|tabular-nums font-features-["smcp"]|) == ~s|tabular-nums font-features-["smcp"]|
    assert tw(~s|font-features-["smcp"] normal-nums|) == ~s|font-features-["smcp"] normal-nums|
    assert tw(~s|font-sans font-features-["smcp"]|) == ~s|font-sans font-features-["smcp"]|
    assert tw("aspect-8/11 aspect-8.5/11") == "aspect-8.5/11"
    assert tw("w-8/11 w-8.5/11") == "w-8.5/11"
    assert tw("inset-1/2 inset-1.25/2.5") == "inset-1.25/2.5"
  end
end
