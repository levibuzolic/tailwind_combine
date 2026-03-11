defmodule TailwindMerge.Class do
  @moduledoc false

  defstruct [:original, :base, :group, :modifiers, :important, :postfix]

  def new(class, class_group_module) do
    case strip_prefix(class, class_group_module) do
      {:external, original} ->
        %__MODULE__{original: original}

      {:ok, normalized_class} ->
        {base, modifiers, postfix} = pop_modifiers(normalized_class)
        {base, important} = pop_important(base)
        group = lookup_group(base, postfix, class_group_module)

        %__MODULE__{
          original: class,
          base: base,
          group: group,
          modifiers: modifiers,
          important: important,
          postfix: postfix
        }
    end
  end

  defp pop_modifiers(class) do
    do_pop_modifiers(class, [], 0, 0, 0, nil, 0)
  end

  defp pop_important(base) when is_binary(base) do
    cond do
      String.ends_with?(base, "!") -> {String.trim_trailing(base, "!"), true}
      String.starts_with?(base, "!") -> {String.trim_leading(base, "!"), true}
      true -> {base, false}
    end
  end

  def modifier_id(%__MODULE__{modifiers: modifiers, important: important}, class_group_module) do
    order_sensitive_modifiers =
      apply(class_group_module, :get_order_sensitive_modifiers, [])
      |> MapSet.new()

    sorted_modifiers =
      modifiers
      |> sort_modifiers(order_sensitive_modifiers)
      |> Enum.join(":")

    case {sorted_modifiers, important} do
      {"", false} -> ""
      {"", true} -> "!"
      {modifier, false} -> modifier
      {modifier, true} -> modifier <> "!"
    end
  end

  defp lookup_group(base, postfix, class_group_module) do
    special_lookup_group(base) ||
      apply(class_group_module, :lookup_group, [base]) ||
      lookup_postfix_group(base, postfix, class_group_module) ||
      lookup_negative_group(base, class_group_module) ||
      arbitrary_property_group(base)
  end

  defp special_lookup_group("text-" <> value) do
    case arbitrary_kind(value) do
      {:variable, nil} -> "text-color"
      {:value, "color"} -> "text-color"
      _ -> nil
    end
  end

  defp special_lookup_group("font-" <> value) do
    case arbitrary_kind(value) do
      {:value, "family-name"} -> "font-family"
      {:variable, "family-name"} -> "font-family"
      {:value, "weight"} -> "font-weight"
      {:variable, "weight"} -> "font-weight"
      {:value, nil} -> "font-weight"
      {:variable, nil} -> "font-weight"
      _ -> nil
    end
  end

  defp special_lookup_group("bg-" <> value) do
    case arbitrary_kind(value) do
      {:value, "position"} -> "background-position"
      {:variable, "position"} -> "background-position"
      {:value, "percentage"} -> "background-position"
      {:value, "size"} -> "background-size"
      {:value, "length"} -> "background-size"
      {:variable, "size"} -> "background-size"
      {:variable, "length"} -> "background-size"
      {:value, "image"} -> "background-image"
      {:value, "url"} -> "background-image"
      {:variable, "image"} -> "background-image"
      {:variable, "url"} -> "background-image"
      {:variable, nil} -> "background-color"
      {:value, nil} -> if image_function?(value), do: "background-image", else: nil
      _ -> nil
    end
  end

  defp special_lookup_group("from-" <> value),
    do: gradient_lookup_group(value, "gradient-from-position")

  defp special_lookup_group("via-" <> value),
    do: gradient_lookup_group(value, "gradient-via-position")

  defp special_lookup_group("to-" <> value),
    do: gradient_lookup_group(value, "gradient-to-position")

  defp special_lookup_group("mask-" <> value), do: mask_lookup_group(value)
  defp special_lookup_group("mask-position-" <> value), do: mask_position_lookup_group(value)
  defp special_lookup_group("mask-size-" <> value), do: mask_size_lookup_group(value)

  defp special_lookup_group("mask-linear-from-color-" <> _value),
    do: "mask-image-linear-from-color"

  defp special_lookup_group("mask-linear-to-color-" <> _value), do: "mask-image-linear-to-color"
  defp special_lookup_group("mask-t-from-color-" <> _value), do: "mask-image-t-from-color"

  defp special_lookup_group("mask-radial-from-color-" <> _value),
    do: "mask-image-radial-from-color"

  defp special_lookup_group("shadow-" <> value) do
    case arbitrary_kind(value) do
      {:value, "color"} -> "box-shadow-color"
      {:variable, "color"} -> "box-shadow-color"
      {:value, "shadow"} -> "box-shadow"
      {:variable, "shadow"} -> "box-shadow"
      {:variable, nil} -> "box-shadow"
      {:value, nil} -> if shadow_value?(value), do: "box-shadow", else: nil
      _ -> nil
    end
  end

  defp special_lookup_group(_base), do: nil

  defp gradient_lookup_group(value, group) do
    cond do
      String.ends_with?(value, "%") -> group
      Regex.match?(~r/^\[(.+)\]$/, value) -> group
      true -> nil
    end
  end

  defp mask_lookup_group(value) do
    case arbitrary_kind(value) do
      {:value, "position"} -> "mask-position"
      {:variable, "position"} -> "mask-position"
      {:value, "size"} -> "mask-size"
      {:variable, "size"} -> "mask-size"
      {:variable, nil} -> "mask-image"
      {:value, nil} -> "mask-image"
      _ -> nil
    end
  end

  defp mask_position_lookup_group(_value), do: "mask-position"
  defp mask_size_lookup_group(_value), do: "mask-size"

  defp strip_prefix(class, class_group_module) do
    case apply(class_group_module, :get_prefix, []) do
      nil ->
        {:ok, class}

      prefix ->
        full_prefix = prefix <> ":"

        if String.starts_with?(class, full_prefix) do
          {:ok, String.replace_prefix(class, full_prefix, "")}
        else
          {:external, class}
        end
    end
  end

  defp lookup_postfix_group(base, postfix, class_group_module) when is_integer(postfix) do
    base
    |> String.slice(0, postfix)
    |> then(&apply(class_group_module, :lookup_group, [&1]))
  end

  defp lookup_postfix_group(_base, _postfix, _class_group_module), do: nil

  defp lookup_negative_group("-" <> rest, class_group_module),
    do: apply(class_group_module, :lookup_group, [rest])

  defp lookup_negative_group(_, _class_group_module), do: nil

  defp arbitrary_property_group("[" <> rest) do
    case String.trim_trailing(rest, "]") do
      value when value == rest ->
        nil

      content ->
        case String.split(content, ":", parts: 2) do
          [property, _value] when property != "" -> "arbitrary.." <> property
          _ -> nil
        end
    end
  end

  defp arbitrary_property_group(_base), do: nil

  defp arbitrary_kind(value) do
    cond do
      Regex.match?(~r/^\[(?:(\w[\w-]*):)?(.+)\]$/i, value) ->
        [_, label, _content] = Regex.run(~r/^\[(?:(\w[\w-]*):)?(.+)\]$/i, value)
        {:value, blank_to_nil(label)}

      Regex.match?(~r/^\((?:(\w[\w-]*):)?(.+)\)$/i, value) ->
        [_, label, _content] = Regex.run(~r/^\((?:(\w[\w-]*):)?(.+)\)$/i, value)
        {:variable, blank_to_nil(label)}

      true ->
        nil
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp image_function?(value) do
    Regex.match?(
      ~r/^\[(url|image|image-set|cross-fade|element|(repeating-)?(linear|radial|conic)-gradient)\(.+\)\]$/,
      value
    )
  end

  defp shadow_value?(value) do
    Regex.match?(
      ~r/^\[(shadow:)?(inset_)?-?((\d+)?\.?(\d+)[a-z]+|0)_-?((\d+)?\.?(\d+)[a-z]+|0).*\]$/,
      value
    )
  end

  defp do_pop_modifiers(
         class,
         modifiers,
         _bracket_depth,
         _paren_depth,
         modifier_start,
         postfix,
         index
       )
       when index >= byte_size(class) do
    base = binary_part(class, modifier_start, byte_size(class) - modifier_start)
    postfix = normalize_postfix(postfix, modifier_start)
    {base, modifiers, postfix}
  end

  defp do_pop_modifiers(
         class,
         modifiers,
         bracket_depth,
         paren_depth,
         modifier_start,
         postfix,
         index
       ) do
    <<_::binary-size(index), current::utf8, _::binary>> = class

    cond do
      bracket_depth == 0 and paren_depth == 0 and current == ?: ->
        modifier = binary_part(class, modifier_start, index - modifier_start)

        do_pop_modifiers(
          class,
          modifiers ++ [modifier],
          bracket_depth,
          paren_depth,
          index + 1,
          postfix,
          index + 1
        )

      bracket_depth == 0 and paren_depth == 0 and current == ?/ ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth,
          paren_depth,
          modifier_start,
          index,
          index + 1
        )

      current == ?[ ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth + 1,
          paren_depth,
          modifier_start,
          postfix,
          index + 1
        )

      current == ?] ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth - 1,
          paren_depth,
          modifier_start,
          postfix,
          index + 1
        )

      current == ?( ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth,
          paren_depth + 1,
          modifier_start,
          postfix,
          index + 1
        )

      current == ?) ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth,
          paren_depth - 1,
          modifier_start,
          postfix,
          index + 1
        )

      true ->
        do_pop_modifiers(
          class,
          modifiers,
          bracket_depth,
          paren_depth,
          modifier_start,
          postfix,
          index + 1
        )
    end
  end

  defp normalize_postfix(nil, _modifier_start), do: nil

  defp normalize_postfix(postfix, modifier_start) when postfix > modifier_start,
    do: postfix - modifier_start

  defp normalize_postfix(_postfix, _modifier_start), do: nil

  defp sort_modifiers(modifiers, order_sensitive_modifiers) do
    {result, current_segment} =
      Enum.reduce(modifiers, {[], []}, fn modifier, {result, current_segment} ->
        if arbitrary_modifier?(modifier) or MapSet.member?(order_sensitive_modifiers, modifier) do
          {result ++ Enum.sort(current_segment) ++ [modifier], []}
        else
          {result, [modifier | current_segment]}
        end
      end)

    result ++ Enum.sort(current_segment)
  end

  defp arbitrary_modifier?("[" <> _rest), do: true
  defp arbitrary_modifier?(_modifier), do: false
end

defimpl String.Chars, for: TailwindMerge.Class do
  def to_string(%TailwindMerge.Class{original: original}), do: original
end
