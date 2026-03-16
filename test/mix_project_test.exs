defmodule TailwindCombine.MixProjectTest do
  use ExUnit.Case, async: true

  test "ex_doc is available in the docs environment" do
    deps = TailwindCombine.MixProject.project()[:deps]

    assert {:ex_doc, _requirement, opts} =
             Enum.find(deps, fn
               {:ex_doc, _, _} -> true
               _ -> false
             end)

    assert opts[:only] == [:dev, :docs]
    assert opts[:runtime] == false
  end
end
