defmodule ConcreteOptics.Applicative do
  @moduledoc """
  An explicit applicative functor record passed to `traverse`.

  An applicative `f` is a "context" or "effect" that values can be lifted into
  and combined. Here we represent it as a plain struct with three function fields
  instead of using Elixir protocols or behaviours, so the applicative can be
  passed as a first-class value.

  ## Fields

  - `pure`    — `a -> f a`                        — lift a plain value into the context
  - `fmap`    — `(a -> b) -> f a -> f b`           — map a function over a value in context
  - `lift_a2` — `(a -> b -> c) -> f a -> f b -> f c` — combine two values in context
  """

  alias ConcreteOptics.Monoid

  @enforce_keys [:pure, :fmap, :lift_a2]
  defstruct [:pure, :fmap, :lift_a2]

  @doc """
  The identity applicative — `f a = a` (no wrapper).

  All operations are the plain function-application equivalents.
  Used internally by `mk_traversal/1` to derive `over` from `traverse`.
  """
  def identity do
    %__MODULE__{
      pure: fn a -> a end,
      fmap: fn f, a -> f.(a) end,
      lift_a2: fn f, a, b -> f.(a, b) end
    }
  end

  @doc """
  The constant-monoid applicative — `f a = m` for some monoid `m`.

  Values of the `a`-type are completely ignored; the applicative accumulates
  monoid values using the supplied monoid's `unit` and `combine`.

  Running a traversal with this applicative and `fn a -> monoid_value(a) end`
  folds all focused elements monoidal​ly. For example, using `Monoid.list_monoid()`
  and `fn a -> [a] end` collects all focused elements into a flat list.

  ## Example

      iex> ap = ConcreteOptics.Applicative.const_monoid(ConcreteOptics.Monoid.list_monoid())
      iex> ap.lift_a2.(fn _, _ -> nil end, [1, 2], [3])
      [1, 2, 3]
  """
  def const_monoid(%Monoid{unit: unit, combine: combine}) do
    %__MODULE__{
      pure: fn _ -> unit end,
      fmap: fn _, m -> m end,
      lift_a2: fn _, m1, m2 -> combine.(m1, m2) end
    }
  end
end
