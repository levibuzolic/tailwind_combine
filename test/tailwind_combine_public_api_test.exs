defmodule TailwindCombinePublicApiTest do
  use ExUnit.Case, async: true

  test "merge/1 uses the default config" do
    assert TailwindCombine.merge("p-2 p-4") == "p-4"

    assert TailwindCombine.merge(["p-2", nil, false, ["hover:p-2", "hover:p-4"]]) ==
             "p-2 hover:p-4"

    assert TailwindCombine.merge("block hidden") == "hidden"
  end
end
