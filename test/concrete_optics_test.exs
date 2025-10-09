defmodule ConcreteOpticsTest do
  @moduledoc """
  This test file is a showcase of optics supported by the library
  as well as an introduction to optics in general.
  """
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Numbers, overload_operators: true

  # Isomorphisms
  # ------------

  # Isomorphisms allow us to change the representation of data
  # without loosing information. Here is a simple example.

  def celsius_fahrenheit do
    celsius_to_fahrenheit = fn
      {:celsius, c} -> {:fahrenheit, 32 + Ratio.new(9, 5) * c}
    end

    fahrenheit_to_celsius = fn
      {:fahrenheit, f} -> {:celsius, (f - 32) * Ratio.new(5, 9)}
    end

    ConcreteOptics.mk_iso(celsius_to_fahrenheit, fahrenheit_to_celsius)
  end

  # Note that we use rational numbers to avoid rounding errors and
  # tagging the temperature value with its unit for clarity. Since
  # this is a custom isomorphism it is a good idea to test it. to achieve
  # that we need a way to generate not too large rational numbers. Size
  # restriction is to avoid under and overflow problems.

  defmodule ConcreteOpticsTest.RationalGenerator do
    require StreamData

    def gen() do
      gen all numerator <- StreamData.integer(-1000..1000),
              denominator <- StreamData.integer(-1000..1000),
              denominator != 0 do
        Ratio.new(numerator, denominator)
      end
    end
  end

  alias ConcreteOpticsTest.RationalGenerator

  property "celsius_fahrenheit is an iso" do
    check all r <- RationalGenerator.gen() do
      # We use the same rational number in both directions to speed up the test.
      c = {:celsius, r}
      f = {:fahrenheit, r}
      assert ConcreteOptics.view_review(celsius_fahrenheit()).(c)
      assert ConcreteOptics.review_view(celsius_fahrenheit()).(f)
    end
  end

  # Now let us put this isomorphism in use. Consider the following function
  # which is defined Celsius in mind.

  def celsius_freezing?({:celsius, r}) do
    Ratio.lt?(r, 0)
  end

  test "celsius_freezing? works" do
    assert celsius_freezing?({:celsius, Ratio.new(-1, 100)})
    assert !celsius_freezing?({:celsius, 0})
    assert !celsius_freezing?({:celsius, Ratio.new(12, 77)})
  end

  # However, by using the iso celsius_fahrenheit we can use the same function
  # on fahrenheit values by first converting fahrenheit to celsius.

  def fahrenheit_freezing?(f) do
    f |> celsius_fahrenheit().review.() |> celsius_freezing?()
  end

  test "celsius_freezing? can be used with fahrenheit" do
    assert fahrenheit_freezing?({:fahrenheit, Ratio.new(30, 1)})
    assert !fahrenheit_freezing?({:fahrenheit, Ratio.new(35, 1)})
  end
end
