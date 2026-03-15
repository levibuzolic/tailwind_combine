defmodule TailwindCombine.Validator do
  @moduledoc """
  Provides built-in validators.
  """

  def any?(_v \\ nil), do: true

  def any_non_arbitrary?(v) do
    not arbitrary?(v) and not arbitrary_variable?(v)
  end

  def arbitrary?(v) do
    match?({:ok, _}, arbitrary_content(v))
  end

  @regex_length ~r/^-?\d*\.?\d+(%|px|em|rem|vh|vw|pt|pc|in|cm|mm|cap|ch|ex|lh|rlh|vi|vb|vmin|vmax|cqw|cqh|cqi|cqb|cqmin|cqmax)$/i
  def arbitrary_length?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "length:") ||
          String.starts_with?(str, "theme(") ||
          String.starts_with?(str, "calc(") ||
          String.starts_with?(str, "min(") ||
          String.starts_with?(str, "max(") ||
          String.starts_with?(str, "clamp(") ||
          String.starts_with?(str, "--") ||
          String.starts_with?(str, "length:--") ||
          str == "0" ||
          Regex.match?(@regex_length, str)
    end
  end

  @regex_color ~r/(#[0-9a-fA-F]{3,8}|rgba?\([^)]+\)|hsla?\([^)]+\)|color-mix\(.+\)|oklab\(.+\)|oklch\(.+\))/
  def arbitrary_color?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "color:") ||
          String.starts_with?(str, "--") ||
          String.starts_with?(str, "color:--") ||
          Regex.match?(@regex_color, str)
    end
  end

  def arbitrary_position?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "position:") || String.starts_with?(str, "percentage:")
    end
  end

  def arbitrary_size?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "size:") || String.starts_with?(str, "length:")
    end
  end

  def arbitrary_number?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "number:") or
          (not String.contains?(str, ":") and str != "" and number?(str))
    end
  end

  def arbitrary_image?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "image:") ||
          String.starts_with?(str, "url:") ||
          Regex.match?(
            ~r/^(url|image|image-set|cross-fade|element|(repeating-)?(linear|radial|conic)-gradient)\(.+\)$/,
            str
          )
    end
  end

  def arbitrary_shadow?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "shadow:") ||
          Regex.match?(~r/^(inset_)?-?((\d+)?\.?(\d+)[a-z]+|0)_-?((\d+)?\.?(\d+)[a-z]+|0)/, str)
    end
  end

  def arbitrary_weight?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        String.starts_with?(str, "weight:") or
          String.starts_with?(str, "number:") or
          (not String.contains?(str, ":") and str != "")
    end
  end

  def arbitrary_family_name?(v) do
    case arbitrary_content(v) do
      :error -> false
      {:ok, str} -> String.starts_with?(str, "family-name:")
    end
  end

  def arbitrary_variable?(v) do
    case arbitrary_content(v) do
      :error -> false
      {:ok, _str} -> Regex.match?(~r/^\((.+)\)$/, v)
    end
  end

  def arbitrary_variable_weight?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        Regex.match?(~r/^\((.+)\)$/, v) and
          (String.starts_with?(str, "weight:") or
             String.starts_with?(str, "number:") or
             not String.contains?(str, ":"))
    end
  end

  def arbitrary_variable_family_name?(v) do
    case arbitrary_content(v) do
      :error -> false
      {:ok, str} -> Regex.match?(~r/^\((.+)\)$/, v) and String.starts_with?(str, "family-name:")
    end
  end

  def arbitrary_variable_length?(v) do
    case arbitrary_content(v) do
      :error -> false
      {:ok, str} -> Regex.match?(~r/^\((.+)\)$/, v) and String.starts_with?(str, "length:")
    end
  end

  def arbitrary_variable_position?(v) do
    case arbitrary_content(v) do
      :error -> false
      {:ok, str} -> Regex.match?(~r/^\((.+)\)$/, v) and String.starts_with?(str, "position:")
    end
  end

  def arbitrary_variable_size?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        Regex.match?(~r/^\((.+)\)$/, v) and
          (String.starts_with?(str, "size:") or String.starts_with?(str, "length:"))
    end
  end

  def arbitrary_variable_image?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        Regex.match?(~r/^\((.+)\)$/, v) and
          (String.starts_with?(str, "image:") or String.starts_with?(str, "url:"))
    end
  end

  def arbitrary_variable_shadow?(v) do
    case arbitrary_content(v) do
      :error ->
        false

      {:ok, str} ->
        Regex.match?(~r/^\((.+)\)$/, v) and
          (String.starts_with?(str, "shadow:") or not String.contains?(str, ":"))
    end
  end

  def integer?(v) do
    case Integer.parse(v) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def float?(v) do
    case Float.parse(v) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def ratio?(v) do
    Regex.match?(~r/^\d+(?:\.\d+)?\/\d+(?:\.\d+)?$/, v)
  end

  def number?(v) do
    integer?(v) || float?(v)
  end

  def percent?(v) do
    Regex.match?(~r/^-?\d*\.?\d+%$/, v)
  end

  @regex_size_abbr ~r/^(\d+)?(xs|sm|md|lg|xl|2xl|3xl|4xl|5xl|6xl|7xl|8xl|9xl)$/
  def size_abbr?(v) do
    Regex.match?(@regex_size_abbr, v)
  end

  @regex_tshirt_size ~r/^(\d+(\.\d+)?)?(xs|sm|md|lg|xl)$/
  def tshirt_size?(v) do
    Regex.match?(@regex_tshirt_size, v)
  end

  def opacity?(v) do
    Regex.match?(~r/^\w*\/\d{1,3}$/, v)
  end

  def custom_color?(v) do
    not reserved_scale_token?(v) and
      (Regex.match?(~r/^[a-z][a-zA-Z0-9-]*$/, v) ||
         Regex.match?(~r/^[a-z][a-zA-Z0-9-]*\/\d{1,3}$/, v))
  end

  defp reserved_scale_token?(v) do
    base =
      case String.split(v, "/", parts: 2) do
        [token, _opacity] -> token
        [token] -> token
      end

    base in ~w(none inner xs sm md lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl)
  end

  defp arbitrary_content(v) do
    cond do
      Regex.match?(~r/^\[(.+)\]$/, v) ->
        [_, content] = Regex.run(~r/^\[(.+)\]$/, v)
        {:ok, content}

      Regex.match?(~r/^\((.+)\)$/, v) ->
        [_, content] = Regex.run(~r/^\((.+)\)$/, v)
        {:ok, content}

      true ->
        :error
    end
  end
end
