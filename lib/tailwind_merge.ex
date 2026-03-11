defmodule TailwindMerge do
  @moduledoc """
  Merge Tailwind CSS classes in Elixir without style conflicts.

  ## Usage

  Use the default Tailwind config directly:

      TailwindMerge.merge("p-2 p-4")
      # "p-4"

  Nested class lists are also supported:

      TailwindMerge.merge(["p-2", nil, ["hover:p-2", "hover:p-4"]])
      # "p-2 hover:p-4"

  To create a dedicated helper module, define one in your project:

      defmodule DemoWeb.ClassHelper do
        use TailwindMerge
      end

  Then, `DemoWeb.ClassHelper.tw/1` will be available to use.

  ## Customization

  To customize the default behaviour, passing options to the `use` call:

     * `:config` - specify the config to use.
     * `:as` - specify the name of generated function.

  Let's customize colors to use:

      defmodule DemoWeb.ClassHelper do
        existing_colors = TailwindMerge.Config.colors()
        new_colors = existing_colors ++ ["primary", "secondary"]
        new_class_groups = TailwindMerge.Config.class_groups(colors: new_colors)

        use TailwindMerge,
          config: TailwindMerge.Config.new(class_groups: new_class_groups),
          as: :merge_class
      end

  Then, call it:

      DemoWeb.ClassHelper.merge_class("text-red-300 text-primary")
      # "text-primary"

  """

  alias TailwindMerge.Config
  alias TailwindMerge.Class
  alias TailwindMerge.ClassGroup
  alias TailwindMerge.DefaultClassGroup

  defmodule DefaultClassGroup do
    @moduledoc false

    @config Config.new()
    @before_compile ClassGroup
  end

  defmacro __using__(opts) do
    config = Keyword.get_lazy(opts, :config, fn -> Macro.escape(Config.new()) end)
    as = Keyword.get(opts, :as, :tw)

    class_group_module = Module.concat(__CALLER__.module, "TailwindMerge.ClassGroup")

    quote do
      defmodule unquote(class_group_module) do
        @config unquote(config)
        @before_compile ClassGroup
      end

      @doc """
      Merges Tailwind CSS classes.
      """
      @spec unquote(as)(binary() | list()) :: binary()
      def unquote(as)(classes), do: TailwindMerge.merge(classes, unquote(class_group_module))
    end
  end

  @doc """
  Merges Tailwind CSS classes using the default TailwindMerge config.
  """
  @spec merge(binary() | list()) :: binary()
  def merge(classes), do: merge(classes, DefaultClassGroup)

  @doc false
  def merge(classes, class_group_module) when is_list(classes) do
    classes
    |> normalize_class_values()
    |> merge(class_group_module)
  end

  def merge(classes, class_group_module) when is_binary(classes) do
    normalized_classes = normalize_class_values(classes)

    normalized_classes
    |> split_classes()
    |> Enum.map(&Class.new(&1, class_group_module))
    |> clean_classes(class_group_module)
    |> Enum.map_join(" ", &to_string/1)
  end

  defp split_classes(classes) when is_binary(classes) do
    Regex.split(~r/\s+/, classes)
  end

  defp flatten_class_values(classes) do
    Enum.flat_map(classes, fn
      nil -> []
      false -> []
      "" -> []
      class when is_binary(class) -> [class]
      nested when is_list(nested) -> flatten_class_values(nested)
      _other -> []
    end)
  end

  defp normalize_class_values(classes) when is_binary(classes), do: String.trim(classes)

  defp normalize_class_values(classes) when is_list(classes) do
    classes
    |> flatten_class_values()
    |> Enum.join(" ")
    |> String.trim()
  end

  defp clean_classes(classes, class_group_module) do
    classes
    |> Enum.reverse()
    |> handle_conflicting_classes(class_group_module)
    |> Enum.reverse()
  end

  defp handle_conflicting_classes(classes, class_group_module) do
    classes
    |> Enum.reduce({[], MapSet.new()}, fn %Class{} = class, {classes, conflicts} ->
      if is_nil(class.group) do
        {[class | classes], conflicts}
      else
        modifier_id = Class.modifier_id(class, class_group_module)
        class_id = modifier_id <> class.group

        if MapSet.member?(conflicts, class_id) do
          {classes, conflicts}
        else
          conflicting_groups =
            apply(class_group_module, :get_conflicting_groups, [class.group, !!class.postfix])

          new_conflicts = Enum.map(conflicting_groups, &(modifier_id <> &1))

          {[class | classes],
           Enum.reduce([class_id | new_conflicts], conflicts, &MapSet.put(&2, &1))}
        end
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end
end
