defmodule ConcreteOptics.Traversal.Laws do
  @moduledoc """
  Well-formedness laws for `ConcreteOptics.Traversal`.

  The Haskell optics-core library states the traversal laws in terms of the
  van Laarhoven representation:

  - **Identity** — `traverseOf o pure ≡ pure`
  - **Composition** — `fmap (traverseOf o f) . traverseOf o g ≡ getCompose . traverseOf o (Compose . fmap f . g)`

  Both laws imply — and are implied by — functor laws on `over`:

  - **Identity** implies `over(id) ≡ id`
  - **Composition** implies `over(f ∘ g) ≡ over(f) ∘ over(g)` (i.e. `over` is a functor map)

  We test these two `over`-based conditions because they are directly expressible
  in Elixir without needing a Compose applicative. They are *necessary* conditions
  for a valid traversal. Note that any traversal built with `mk_traversal/1` from a
  lawful van Laarhoven function already satisfies the full traversal laws.

  ## Usage in a property test

      property "list_traversal is well-formed" do
        check all s <- list_of(integer()) do
          assert ConcreteOptics.Traversal.Laws.over_identity(my_traversal(), s)
        end

        check all s <- list_of(integer()) do
          f = fn x -> x + 1 end
          g = fn x -> x * 2 end
          assert ConcreteOptics.Traversal.Laws.over_composition(my_traversal(), f, g, s)
        end
      end
  """

  alias ConcreteOptics.Traversal

  @doc """
  **OverIdentity** — `over(id) ≡ id`

  Applying `over` with the identity function leaves the structure unchanged.

  `traversal.over.(fn x -> x end).(s) == s`

  Quantified over all `s : S`.
  """
  def over_identity(%Traversal{} = traversal, s) do
    traversal.over.(fn x -> x end).(s) == s
  end

  @doc """
  **OverComposition** — `over(f ∘ g) ≡ over(f) ∘ over(g)`

  Applying `over` with a composed function is the same as applying `over` with
  each function in sequence. Equivalently: `over` is a functor map on the
  endomorphisms of the focused type.

  `traversal.over.(fn x -> f.(g.(x)) end).(s) == traversal.over.(f).(traversal.over.(g).(s))`

  Quantified over all `s : S`, `f : B -> C`, `g : A -> B`.
  Note: for the type-preserving case `A = B = C`.
  """
  def over_composition(%Traversal{} = traversal, f, g, s) do
    traversal.over.(fn x -> f.(g.(x)) end).(s) ==
      traversal.over.(f).(traversal.over.(g).(s))
  end
end
