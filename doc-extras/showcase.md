# Showcase

```elixir
defmodule ConcreteOpticsTest do
  @moduledoc """
  This test file also serves as a showcase of the ConcreteOptics library.
  """

  use ExUnit.Case, async: true
  use ExUnitProperties
  use Numbers, overload_operators: true

  import ConcreteOptics

  alias ConcreteOptics.Applicative
  alias ConcreteOptics.Iso.Laws, as: IsoLaws
  alias ConcreteOptics.Lens.Laws, as: LensLaws

  # ============================================================
  # Helper functions used throughout the showcase
  # ============================================================

  # Returns the first focused element, or :no_match if the optic sees nothing.
  defp preview(optic, s) do
    case optic.to_list.(s) do
      [a | _] -> a
      [] -> :no_match
    end
  end

  # Replaces the focused element with a constant value.
  defp put(optic, b, s), do: optic.over.(fn _ -> b end).(s)

  # A lens that focuses on a single key of a map.
  defp field_lens(key) do
    mk_lens(fn m -> m[key] end, fn m, v -> Map.put(m, key, v) end)
  end

  # A traversal that optionally focuses on a map key:
  # focuses on the value when the key is present, on nothing otherwise.
  # Using over on a missing key leaves the map unchanged.
  defp maybe_field(key) do
    mk_traversal(fn ap ->
      fn f ->
        fn m ->
          case Map.fetch(m, key) do
            {:ok, v} -> ap.fmap.(fn new_v -> Map.put(m, key, new_v) end, f.(v))
            :error -> ap.pure.(m)
          end
        end
      end
    end)
  end

  # A prism that matches values satisfying a predicate.
  # review is the identity — the prism does not wrap or tag the value.
  defp predicate_prism(pred) do
    mk_prism_(fn x -> x end, fn s ->
      if pred.(s), do: {:ok, s}, else: :no_match
    end)
  end

  # A prism for non-empty lists: focuses on the head/tail decomposition.
  # review reconstructs the list from a %{head: h, tail: t} map.
  # When f returns a non-map value (e.g. a scalar), review passes it through,
  # making the prism usable for type-changing transformations.
  defp cons_prism do
    mk_prism(
      fn b ->
        case b do
          %{head: h, tail: t} -> [h | t]
          other -> other
        end
      end,
      fn
        [] -> {:no_match, []}
        [h | t] -> {:ok, %{head: h, tail: t}}
      end
    )
  end

  # A traversal over every element of a list.
  defp list_traversal do
    mk_traversal(fn ap ->
      fn f ->
        fn list ->
          Enum.reduce(list, ap.pure.([]), fn x, acc ->
            ap.lift_a2.(fn a, b -> a ++ b end, acc, ap.fmap.(fn v -> [v] end, f.(x)))
          end)
        end
      end
    end)
  end

  # StreamData generator for rational numbers (using the Ratio library).
  defp rational_gen do
    map(
      tuple({integer(), positive_integer()}),
      fn {n, d} -> Ratio.new(n, d) end
    )
  end

  # A generic validation applicative where errors are combined using
  # the given binary function. Success values are accumulated in a list.
  defp validation_ap(combine_errors) do
    %Applicative{
      pure: fn a -> {:ok, a} end,
      fmap: fn f, result ->
        case result do
          {:ok, a} -> {:ok, f.(a)}
          {:error, _} = err -> err
        end
      end,
      lift_a2: fn f, ra, rb ->
        case {ra, rb} do
          {{:ok, a}, {:ok, b}} -> {:ok, f.(a, b)}
          {{:error, e1}, {:error, e2}} -> {:error, combine_errors.(e1, e2)}
          {{:error, _} = err, _} -> err
          {_, {:error, _} = err} -> err
        end
      end
    }
  end

  # Fails as soon as the first error is encountered.
  defp fail_fast_ap, do: validation_ap(fn e, _ -> e end)

  # Collects all errors into a list (errors must already be lists).
  defp collect_errors_ap, do: validation_ap(fn e1, e2 -> e1 ++ e2 end)

  # Counts all errors (errors must already be integers).
  defp count_errors_ap, do: validation_ap(fn e1, e2 -> e1 + e2 end)

  # Square root that signals failure for negative inputs.
  defp fancy_sqrt(x) when x < 0,
    do: {:error, "Cannot take the square root of #{x}"}

  defp fancy_sqrt(x),
    do: {:ok, :math.sqrt(x)}

  # Transforms the error component of a validation result.
  defp map_failure(f, {:error, e}), do: {:error, f.(e)}
  defp map_failure(_f, {:ok, _} = ok), do: ok

  # ============================================================
  # Isomorphisms
  # ============================================================

  # Isomorphisms allow us to change the representation of data
  # without losing information. Here is a simple example.
  #
  # We use the Ratio library so the round-trip laws hold exactly,
  # with no floating-point error.

  defp celsius_fahrenheit do
    mk_iso(
      fn c -> c * Ratio.new(9, 5) + 32 end,
      fn f -> (f - 32) * Ratio.new(5, 9) end
    )
  end

  # It is good practice to check that a custom optic is lawful.
  # The Laws modules provide the necessary predicate functions.

  property "celsius_fahrenheit - view then review is identity" do
    check all c <- rational_gen() do
      assert IsoLaws.review_then_view(celsius_fahrenheit(), c)
    end
  end

  property "celsius_fahrenheit - review then view is identity" do
    check all f <- rational_gen() do
      assert IsoLaws.view_then_review(celsius_fahrenheit(), f)
    end
  end

  # Consider this function defined with Celsius in mind.

  defp celsius_freezing?(c), do: Ratio.compare(c, 0) == :lt

  # By using celsius_fahrenheit we can apply celsius_freezing? to
  # Fahrenheit values: the iso converts them to Celsius first.

  test "celsius_freezing? via iso" do
    assert celsius_freezing?(celsius_fahrenheit().review.(30))
    refute celsius_freezing?(celsius_fahrenheit().review.(35))
  end

  # Here is a more interesting example: transforming a value in
  # one representation by using a function written for the other.

  defp increase_fahrenheit(diff), do: fn f -> f + diff end
  defp increase_celsius(diff), do: fn c -> c + diff end

  test "increase_fahrenheit operates on Celsius via over" do
    # Celsius 1 → Fahrenheit 33.8, then +1.8 → Fahrenheit 35.6 → Celsius 2
    assert celsius_fahrenheit().over.(increase_fahrenheit(Ratio.new(9, 5))).(1) ==
             Ratio.new(2, 1)
  end

  # We can also go the other direction by inverting the iso.

  defp fahrenheit_celsius, do: invert_iso(celsius_fahrenheit())

  test "increase_celsius operates on Fahrenheit via inverted iso" do
    # Fahrenheit 1 → Celsius (1-32)*5/9, then +5/9 → a new Celsius → back to Fahrenheit 2
    assert fahrenheit_celsius().over.(increase_celsius(Ratio.new(5, 9))).(1) ==
             Ratio.new(2, 1)
  end

  # It is also possible to work with more than two representations.
  # By composing isos we get a Kelvin ↔ Fahrenheit iso for free.

  defp celsius_kelvin do
    mk_iso(fn c -> c + 273 end, fn k -> k - 273 end)
  end

  property "celsius_kelvin - view then review is identity" do
    check all c <- integer() do
      assert IsoLaws.review_then_view(celsius_kelvin(), c)
    end
  end

  property "celsius_kelvin - review then view is identity" do
    check all k <- integer() do
      assert IsoLaws.view_then_review(celsius_kelvin(), k)
    end
  end

  defp kelvin_fahrenheit do
    compose(invert_iso(celsius_kelvin()), celsius_fahrenheit())
  end

  test "kelvin_fahrenheit composition: over with increase_fahrenheit" do
    # Kelvin 1 → Celsius -272 → Fahrenheit (-272*9/5+32).
    # Increase by 9/5°F (= 1°C = 1K). Result: Kelvin 2.
    assert kelvin_fahrenheit().over.(increase_fahrenheit(Ratio.new(9, 5))).(1) ==
             Ratio.new(2, 1)
  end

  # ============================================================
  # Lenses
  # ============================================================

  # Lenses are a generalisation of field accessors and modifiers.
  # Consider the following example.

  @location %{latitude: 51.340199, longitude: 12.360103}

  @weather_data %{
    temperature: %{celsius: 0},
    date: "2017-06-09",
    location: @location
  }

  # field_lens focuses on a single map key; composing two of them
  # gives access to a nested field.

  defp weather_latitude_lens do
    compose(field_lens(:location), field_lens(:latitude))
  end

  test "lens imitates field accessor" do
    assert weather_latitude_lens().view.(@weather_data) ==
             get_in(@weather_data, [:location, :latitude])
  end

  test "lens imitates field modifier" do
    assert weather_latitude_lens().over.(fn _ -> 0.0 end).(@weather_data) ==
             put_in(@weather_data, [:location, :latitude], 0.0)
  end

  # Lenses really shine when composed with other optics.
  # By composing a lens with an isomorphism we obtain a *virtual field*:
  # a field that does not exist in the data but can be read and written
  # as if it did.

  # The virtual fahrenheit field of weather_data:
  # compose through field_lens(:temperature), then field_lens(:celsius), then the iso.
  defp weather_fahrenheit_lens do
    compose_all([field_lens(:temperature), field_lens(:celsius), celsius_fahrenheit()])
  end

  test "virtual fahrenheit field: view" do
    # temperature.celsius is 0°C; the iso maps it to 32°F (exact: Ratio 32/1).
    assert weather_fahrenheit_lens().view.(@weather_data) == Ratio.new(32, 1)
  end

  test "virtual fahrenheit field: over" do
    # Increase by 1.8°F = 1°C: celsius goes from 0 to 1 (exact: Ratio 1/1).
    updated =
      weather_fahrenheit_lens().over.(increase_fahrenheit(Ratio.new(9, 5))).(
        @weather_data
      )

    assert updated == %{
             temperature: %{celsius: Ratio.new(1, 1)},
             date: "2017-06-09",
             location: @location
           }
  end

  test "virtual fahrenheit field: put" do
    # Set to 212°F = 100°C (exact: Ratio 100/1).
    updated = put(weather_fahrenheit_lens(), 212, @weather_data)

    assert updated == %{
             temperature: %{celsius: Ratio.new(100, 1)},
             date: "2017-06-09",
             location: @location
           }
  end

  # Here is another virtual field example. The weight struct stores
  # net weight and tare; gross (= net + tare) is the virtual field.

  @net_tare_weight %{net: 100, tare: 15}

  defp net_tare_iso do
    mk_iso(
      fn w -> %{gross: w.net + w.tare, tare: w.tare} end,
      fn w -> %{net: w.gross - w.tare, tare: w.tare} end
    )
  end

  defp virtual_gross_field do
    compose(net_tare_iso(), field_lens(:gross))
  end

  test "virtual gross field: view" do
    assert virtual_gross_field().view.(@net_tare_weight) == 115
  end

  test "virtual gross field: over" do
    assert virtual_gross_field().over.(fn g -> g + 10 end).(@net_tare_weight) ==
             %{net: 110, tare: 15}
  end

  test "virtual gross field: put" do
    assert put(virtual_gross_field(), 80, @net_tare_weight) == %{net: 65, tare: 15}
  end

  # We can also build the same virtual field by hand with mk_lens,
  # specifying view and update directly.

  defp handmade_virtual_gross_field do
    mk_lens(
      fn w -> w.net + w.tare end,
      fn w, new_gross -> %{net: new_gross - w.tare, tare: w.tare} end
    )
  end

  # Manually constructed optics should always be tested for well-formedness.

  property "handmade_virtual_gross_field - get_put" do
    check all net <- integer(), tare <- integer(), new_gross <- integer() do
      assert LensLaws.get_put(
               handmade_virtual_gross_field(),
               %{net: net, tare: tare},
               new_gross
             )
    end
  end

  property "handmade_virtual_gross_field - put_get" do
    check all net <- integer(), tare <- integer() do
      assert LensLaws.put_get(handmade_virtual_gross_field(), %{net: net, tare: tare})
    end
  end

  property "handmade_virtual_gross_field - put_put" do
    check all net <- integer(), tare <- integer(), g1 <- integer(), g2 <- integer() do
      assert LensLaws.put_put(
               handmade_virtual_gross_field(),
               %{net: net, tare: tare},
               g1,
               g2
             )
    end
  end

  # We can also verify that both versions produce identical results.

  test "composed and handmade gross field agree" do
    assert virtual_gross_field().view.(@net_tare_weight) ==
             handmade_virtual_gross_field().view.(@net_tare_weight)

    over_fn = fn g -> g + 10 end

    assert virtual_gross_field().over.(over_fn).(@net_tare_weight) ==
             handmade_virtual_gross_field().over.(over_fn).(@net_tare_weight)

    assert put(virtual_gross_field(), 80, @net_tare_weight) ==
             put(handmade_virtual_gross_field(), 80, @net_tare_weight)
  end

  # ============================================================
  # Prisms
  # ============================================================

  # Prisms implement a form of pattern matching where you commit to
  # one branch. The cons_prism decomposes a non-empty list into its
  # head and tail.

  test "cons_prism: empty list has no decomposition" do
    assert preview(cons_prism(), []) == :no_match
  end

  test "cons_prism: non-empty list has a head/tail decomposition" do
    assert preview(cons_prism(), [1, 2, 3]) == %{head: 1, tail: [2, 3]}
  end

  test "cons_prism: review reconstructs the list" do
    assert cons_prism().review.(%{head: 1, tail: [2, 3]}) == [1, 2, 3]
  end

  # over applies a function to the focused decomposition. When f returns
  # a %{head, tail} map, review reconstructs the list. When f returns
  # a scalar (as average does), review passes the scalar through unchanged —
  # a type-changing use of the prism.

  defp average(%{head: h, tail: t}), do: div(h + Enum.sum(t), 1 + length(t))

  test "cons_prism: over on empty list is a no-op" do
    assert cons_prism().over.(&average/1).([]) == []
  end

  test "cons_prism: over on non-empty list applies f to decomposition" do
    assert cons_prism().over.(&average/1).([1, 2, 3]) == 2
  end

  test "cons_prism: over with type-preserving f reconstructs the list" do
    incr_head = fn %{head: h, tail: t} -> %{head: h + 1, tail: t} end
    assert cons_prism().over.(incr_head).([5, 2, 3]) == [6, 2, 3]
    assert cons_prism().over.(incr_head).([]) == []
  end

  # A predicate prism matches values that satisfy a condition.
  # review is the identity: the prism does not wrap the matched value.

  defp positive_prism, do: predicate_prism(fn x -> x > 0 end)

  test "positive_prism: no match on negative value" do
    assert preview(positive_prism(), -5) == :no_match
  end

  test "positive_prism: matches positive value" do
    assert preview(positive_prism(), 5) == 5
  end

  # ============================================================
  # Traversals
  # ============================================================

  # The traverse capability generalises structured iteration.
  # When combined with the const_monoid applicative, it becomes a fold.
  # Here is a very indirect implementation of length:

  defp list_length(list) do
    list_traversal().traverse.(
      Applicative.const_monoid(ConcreteOptics.Monoid.list_monoid())
    ).(fn _ -> [1] end).(list)
    |> length()
  end

  test "list_length via traverse" do
    assert list_length([1, 2, 3, 4, 5]) == 5
    assert list_length([]) == 0
  end

  # Optics really shine when composed. Here we combine a list traversal,
  # an optional map-key traversal, and a predicate prism to focus on
  # specific elements deep inside a nested structure.

  @nested_data [%{a: 1, b: 2}, %{c: 3}, %{a: -5}, %{a: 7, z: 22}]

  defp each_positive_a do
    compose_all([
      list_traversal(),
      maybe_field(:a),
      positive_prism()
    ])
  end

  test "to_list with filtering condition" do
    # Traverses each map, focuses on :a if present, then keeps only positives.
    assert each_positive_a().to_list.(@nested_data) == [1, 7]
  end

  test "over modifies only matching elements" do
    # Increment only the positive :a values; leave the rest untouched.
    assert each_positive_a().over.(fn x -> x + 1 end).(@nested_data) ==
             [%{a: 2, b: 2}, %{c: 3}, %{a: -5}, %{a: 8, z: 22}]
  end

  # There are many useful applicative structures that can be used with
  # traverse. Here are examples for validating lists of numbers.

  @some_numbers [1, -4, 6, 7, -9, 7, -3]
  @some_nonneg_numbers [1, 16, 25, 9, 1, 4]

  # Fail fast: stop at the first error.

  defp fail_fast_validate(numbers) do
    list_traversal().traverse.(fail_fast_ap()).(fn x -> fancy_sqrt(x) end).(numbers)
  end

  test "fail_fast_validate: returns only the first error" do
    assert fail_fast_validate(@some_numbers) ==
             {:error, "Cannot take the square root of -4"}
  end

  test "fail_fast_validate: returns result list when all inputs are valid" do
    assert fail_fast_validate(@some_nonneg_numbers) ==
             {:ok, [1.0, 4.0, 5.0, 3.0, 1.0, 2.0]}
  end

  # Collect all errors: keep going and accumulate every failure.
  # We wrap each individual error in a list so they can be concatenated.

  defp collect_errors_validate(numbers) do
    list_traversal().traverse.(collect_errors_ap()).(fn x ->
      map_failure(fn e -> [e] end, fancy_sqrt(x))
    end).(numbers)
  end

  test "collect_errors_validate: returns all errors" do
    assert collect_errors_validate(@some_numbers) ==
             {:error,
              [
                "Cannot take the square root of -4",
                "Cannot take the square root of -9",
                "Cannot take the square root of -3"
              ]}
  end

  test "collect_errors_validate: returns result list when all inputs are valid" do
    assert collect_errors_validate(@some_nonneg_numbers) ==
             {:ok, [1.0, 4.0, 5.0, 3.0, 1.0, 2.0]}
  end

  # Count errors: like collect, but only track the count.
  # Each error is mapped to 1 before being combined with +.

  defp count_errors_validate(numbers) do
    list_traversal().traverse.(count_errors_ap()).(fn x ->
      map_failure(fn _ -> 1 end, fancy_sqrt(x))
    end).(numbers)
  end

  test "count_errors_validate: returns the number of errors" do
    assert count_errors_validate(@some_numbers) == {:error, 3}
  end

  test "count_errors_validate: returns result list when all inputs are valid" do
    assert count_errors_validate(@some_nonneg_numbers) ==
             {:ok, [1.0, 4.0, 5.0, 3.0, 1.0, 2.0]}
  end

  # Finally, traversals are not limited to flat lists. Here we define a
  # traversal over the integer leaves of an arbitrarily nested list structure
  # such as [1, [2, 3], [[4], 5]].

  defp nested_list_traversal do
    mk_traversal(fn ap ->
      fn f ->
        fn structure ->
          do_traverse(ap, f, structure)
        end
      end
    end)
  end

  defp do_traverse(ap, f, x) when is_integer(x), do: f.(x)
  defp do_traverse(ap, _f, x) when not is_list(x), do: ap.pure.(x)

  defp do_traverse(ap, _f, []), do: ap.pure.([])

  defp do_traverse(ap, f, [h | t]) do
    ap.lift_a2.(fn a, b -> [a | b] end, do_traverse(ap, f, h), do_traverse(ap, f, t))
  end

  @some_nested [1, 2, [[3, 4], 5], 6, [7, [8, [9, [10, 11]]]]]

  defp each_even_nested do
    compose(nested_list_traversal(), predicate_prism(fn x -> rem(x, 2) == 0 end))
  end

  test "nested traversal: to_list collects integer leaves" do
    assert nested_list_traversal().to_list.(@some_nested) ==
             [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  end

  test "nested traversal with predicate prism: filters even leaves" do
    assert each_even_nested().to_list.(@some_nested) == [2, 4, 6, 8, 10]
  end

  test "nested traversal with predicate prism: modifies even leaves only" do
    assert each_even_nested().over.(fn x -> x + 1 end).(@some_nested) ==
             [1, 3, [[3, 5], 5], 7, [7, [9, [9, [11, 11]]]]]
  end
end
```

