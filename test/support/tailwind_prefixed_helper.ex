defmodule TailwindPrefixedHelper do
  @moduledoc false

  use TailwindMerge, as: :tw, config: TailwindMerge.Config.new(prefix: "tw")
end
