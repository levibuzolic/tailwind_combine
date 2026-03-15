defmodule TailwindPrefixedHelper do
  @moduledoc false

  use TailwindCombine, as: :tw, config: TailwindCombine.Config.new(prefix: "tw")
end
