defmodule ConcreteOptics do
  @moduledoc """
  A simple capability-based optics library.

  Each optic is a struct whose fields are the capabilities it supports:

  | Optic      | view | to_list | review | over | traverse |
  |------------|:----:|:-------:|:------:|:----:|:--------:|
  | `Iso`      |  ✓   |    ✓    |   ✓    |  ✓   |    ✓     |
  | `Lens`     |  ✓   |    ✓    |        |  ✓   |    ✓     |
  | `Prism`    |      |    ✓    |   ✓    |  ✓   |    ✓     |
  | `Traversal`|      |    ✓    |        |  ✓   |    ✓     |
  | `Getter`   |  ✓   |    ✓    |        |      |          |
  | `Setter`   |      |         |        |  ✓   |          |
  | `Fold`     |      |    ✓    |        |      |          |

  ## Constructors

  - `mk_iso/2`       — build an `Iso` from view + review
  - `mk_lens/2`      — build a `Lens` from view + update
  - `mk_prism/2`     — build a `Prism` from review + match (`{:ok,a}|{:no_match,t}`)
  - `mk_prism_/2`    — simplified type-preserving prism (`:no_match` variant)
  - `mk_traversal/1` — build a `Traversal` from a van-Laarhoven traverse function
  - `mk_getter/1`    — build a `Getter` from a view function
  - `mk_setter/1`    — build a `Setter` from an over function
  - `folding/1`      — build a `Fold` from a `s -> [a]` function

  ## Composition

  - `compose/2`      — compose two optics (result type = capability intersection)
  - `compose_all/1`  — compose a non-empty list of optics left-to-right

  ## Applicative and Monoid records

  Used with the `traverse` capability:
  - `ConcreteOptics.Applicative.identity/0`
  - `ConcreteOptics.Applicative.const_monoid/1`
  - `ConcreteOptics.Monoid.list_monoid/0`
  """

  alias ConcreteOptics.Iso
  alias ConcreteOptics.Lens
  alias ConcreteOptics.Prism
  alias ConcreteOptics.Traversal
  alias ConcreteOptics.Getter
  alias ConcreteOptics.Setter
  alias ConcreteOptics.Fold

  # -- Iso -------------------------------------------------------------------

  @doc """
  Build an `Iso s t a b` from `view : s -> a` and `review : b -> t`.

  See `ConcreteOptics.Iso.new/2`.
  """
  defdelegate mk_iso(view, review), to: Iso, as: :new

  @doc """
  Invert an isomorphism, swapping `view` and `review`.

  See `ConcreteOptics.Iso.invert/1`.
  """
  defdelegate invert_iso(iso), to: Iso, as: :invert

  @doc """
  The identity isomorphism.

  See `ConcreteOptics.Iso.identity/0`.
  """
  defdelegate iso_identity(), to: Iso, as: :identity

  @doc """
  Transport a function across an isomorphism.

  See `ConcreteOptics.Iso.transport/2`.
  """
  defdelegate transport(iso, f), to: Iso

  # -- Lens ------------------------------------------------------------------

  @doc """
  Build a `Lens s t a b` from `view : s -> a` and `update : s -> b -> t`.

  See `ConcreteOptics.Lens.new/2`.
  """
  defdelegate mk_lens(view, update), to: Lens, as: :new

  # -- Prism -----------------------------------------------------------------

  @doc """
  Build a `Prism s t a b` from `review : b -> t` and
  `match : s -> {:ok, a} | {:no_match, t}`.

  See `ConcreteOptics.Prism.new/2`.
  """
  defdelegate mk_prism(review, match), to: Prism, as: :new

  @doc """
  Build a type-preserving `Prism s s a b` from `review : b -> s` and
  `match : s -> {:ok, a} | :no_match`.

  See `ConcreteOptics.Prism.new_/2`.
  """
  defdelegate mk_prism_(review, match), to: Prism, as: :new_

  # -- Traversal -------------------------------------------------------------

  @doc """
  Build a `Traversal s t a b` from a van-Laarhoven traverse function
  `ap -> (a -> f b) -> (s -> f t)`.

  See `ConcreteOptics.Traversal.new/1`.
  """
  defdelegate mk_traversal(traverse_fn), to: Traversal, as: :new

  # -- Getter ----------------------------------------------------------------

  @doc """
  Build a `Getter s a` from `view : s -> a`.

  See `ConcreteOptics.Getter.new/1`.
  """
  defdelegate mk_getter(view), to: Getter, as: :new

  # -- Setter ----------------------------------------------------------------

  @doc """
  Build a `Setter s t a b` from `over_fn : (a -> b) -> s -> t`.

  See `ConcreteOptics.Setter.new/1`.
  """
  defdelegate mk_setter(over_fn), to: Setter, as: :new

  # -- Fold ------------------------------------------------------------------

  @doc """
  Build a `Fold s a` from `to_list_fn : s -> [a]`.

  See `ConcreteOptics.Fold.new/1`.
  """
  defdelegate folding(to_list_fn), to: Fold, as: :new

  # -- Composition -----------------------------------------------------------

  @doc """
  Compose two optics.  The result type equals the capability intersection.

  See `ConcreteOptics.Compose.compose/2` for the full dispatch table and
  error behaviour on incompatible pairs.
  """
  defdelegate compose(o1, o2), to: ConcreteOptics.Compose

  @doc """
  Compose a non-empty list of optics left-to-right.

  See `ConcreteOptics.Compose.compose_all/1`.
  """
  defdelegate compose_all(optics), to: ConcreteOptics.Compose
end
