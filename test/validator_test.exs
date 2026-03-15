# credo:disable-for-this-file
defmodule TailwindCombineValidatorTest do
  use ExUnit.Case, async: true

  alias TailwindCombine.Validator

  test "matches upstream validator semantics" do
    assert Validator.any?()
    assert Validator.any_non_arbitrary?("test")
    assert Validator.any_non_arbitrary?("1234-hello-world")
    assert Validator.any_non_arbitrary?("[hello")
    refute Validator.any_non_arbitrary?("[test]")
    refute Validator.any_non_arbitrary?("(test)")

    assert Validator.arbitrary_family_name?("[family-name:Open_Sans]")
    assert Validator.arbitrary_family_name?("[family-name:var(--my-font)]")
    refute Validator.arbitrary_family_name?("[Open_Sans]")

    assert Validator.arbitrary_image?("[url:var(--my-url)]")
    assert Validator.arbitrary_image?("[url(something)]")
    assert Validator.arbitrary_image?("[image:bla]")
    assert Validator.arbitrary_image?("[linear-gradient(something)]")
    refute Validator.arbitrary_image?("[bla]")

    assert Validator.arbitrary_length?("[3.7%]")
    assert Validator.arbitrary_length?("[481px]")
    assert Validator.arbitrary_length?("[length:var(--arbitrary)]")
    refute Validator.arbitrary_length?("[1]")

    assert Validator.arbitrary_number?("[number:black]")
    assert Validator.arbitrary_number?("[450]")
    refute Validator.arbitrary_number?("[2px]")

    assert Validator.arbitrary_position?("[position:2px]")
    assert Validator.arbitrary_position?("[percentage:bla]")
    refute Validator.arbitrary_position?("[2px]")

    assert Validator.arbitrary_shadow?("[0_35px_60px_-15px_rgba(0,0,0,0.3)]")
    assert Validator.arbitrary_shadow?("[inset_0_1px_0,inset_0_-1px_0]")
    assert Validator.arbitrary_shadow?("[0_0_#00f]")
    refute Validator.arbitrary_shadow?("[#00f]")

    assert Validator.arbitrary_weight?("[weight:400]")
    assert Validator.arbitrary_weight?("[number:var(--my-weight)]")
    assert Validator.arbitrary_weight?("[bold]")
    refute Validator.arbitrary_weight?("[family-name:test]")

    assert Validator.arbitrary_size?("[size:2px]")
    assert Validator.arbitrary_size?("[length:bla]")
    refute Validator.arbitrary_size?("[percentage:bla]")

    assert Validator.arbitrary?("[1]")
    assert Validator.arbitrary?("[auto,auto,minmax(0,1fr),calc(100vw-50%)]")
    refute Validator.arbitrary?("[]")

    assert Validator.arbitrary_variable?("(1)")
    assert Validator.arbitrary_variable?("(label:--my-arbitrary-variable)")
    refute Validator.arbitrary_variable?("()")

    assert Validator.arbitrary_variable_family_name?("(family-name:test)")
    refute Validator.arbitrary_variable_family_name?("(test)")

    assert Validator.arbitrary_variable_image?("(image:test)")
    assert Validator.arbitrary_variable_image?("(url:test)")
    refute Validator.arbitrary_variable_image?("(test)")

    assert Validator.arbitrary_variable_length?("(length:test)")
    refute Validator.arbitrary_variable_length?("(test)")

    assert Validator.arbitrary_variable_position?("(position:test)")
    refute Validator.arbitrary_variable_position?("(test)")

    assert Validator.arbitrary_variable_shadow?("(shadow:test)")
    assert Validator.arbitrary_variable_shadow?("(test)")
    refute Validator.arbitrary_variable_shadow?("(other:test)")

    assert Validator.arbitrary_variable_size?("(size:test)")
    assert Validator.arbitrary_variable_size?("(length:test)")
    refute Validator.arbitrary_variable_size?("(test)")

    assert Validator.arbitrary_variable_weight?("(weight:test)")
    assert Validator.arbitrary_variable_weight?("(number:test)")
    assert Validator.arbitrary_variable_weight?("(--my-weight)")
    refute Validator.arbitrary_variable_weight?("[weight:test]")

    assert Validator.ratio?("1/2")
    refute Validator.ratio?("1")

    assert Validator.integer?("123")
    refute Validator.integer?("8312.2")

    assert Validator.number?("1.2")
    refute Validator.number?("one")

    assert Validator.percent?("100.001%")
    assert Validator.percent?(".01%")
    refute Validator.percent?("0")

    assert Validator.tshirt_size?("xs")
    assert Validator.tshirt_size?("2.5xl")
    assert Validator.tshirt_size?("10xl")
    refute Validator.tshirt_size?("xl3")
  end
end
