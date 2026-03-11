defmodule TailwindMergePublicApiTest do
  use ExUnit.Case, async: true

  test "merge/1 uses the default config" do
    assert TailwindMerge.merge("p-2 p-4") == "p-4"
    assert TailwindMerge.merge(["p-2", nil, false, ["hover:p-2", "hover:p-4"]]) == "p-2 hover:p-4"
    assert TailwindMerge.merge("block hidden") == "hidden"
  end
end
