defmodule ConcreteOptics.Traversal do
  @moduledoc """
  Traversal — `Traversal s t a b`.

  A traversal focuses on zero or more elements inside a structure.  It is the
  most general optic that can both read and write: it supports `to_list`,
  `over`, and `traverse`, but neither `view` (no guaranteed single focus) nor
  `review` (cannot build a whole from a part alone).

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |      |    ✓    |        |  ✓   |    ✓     |

  ## Fields

  - `over`     — `(a -> b) -> (s -> t)`
  - `to_list`  — `s -> [a]`
  - `traverse` — `Applicative f -> (a -> f b) -> (s -> f t)`
  """

  alias ConcreteOptics.Applicative
  alias ConcreteOptics.Monoid

  @enforce_keys [:over, :to_list, :traverse]
  defstruct [:over, :to_list, :traverse]

  @doc """
  Construct a `Traversal s t a b` from a van-Laarhoven-style traverse function.

  The argument `traverse_fn` must have the signature:

      traverse_fn : Applicative f -> (a -> f b) -> (s -> f t)

  The remaining capabilities are derived using the built-in applicatives:

  - `to_list s  = traverse_fn(Applicative.const_monoid(list_monoid), fn a -> [a] end, s)`
  - `over f     = traverse_fn(Applicative.identity(), f)`

  Corresponds to Haskell's
  `traversalVL :: TraversalVL s t a b -> Traversal s t a b`.
  """
  def new(traverse_fn) do
    list_ap = Applicative.const_monoid(Monoid.list_monoid())
    id_ap = Applicative.identity()

    %__MODULE__{
      traverse: traverse_fn,
      to_list: fn s -> traverse_fn.(list_ap).(fn a -> [a] end).(s) end,
      over: fn f -> traverse_fn.(id_ap).(f) end
    }
  end
end
