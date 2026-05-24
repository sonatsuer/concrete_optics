defmodule ConcreteOptics.Setter.Laws do
  @moduledoc """
  Well-formedness laws for `ConcreteOptics.Setter`.

  The Haskell optics-core library gives two well-formedness conditions for
  setters under the name "functoriality":

  - **Identity** — `over s id ≡ id`
  - **Composition** — `over s f . over s g ≡ over s (f . g)`

  It also mentions **PutPut** (setting twice equals setting once):

  - **PutPut** — `set l v' (set l v s) ≡ set l v' s`

  PutPut follows from the composition law (composing two constant functions
  gives the outer constant), but it is included here as a separate check
  because it is the most practically significant condition and easiest to
  generate test inputs for.

  ## Usage in a property test

      property "map_setter is well-formed" do
        check all s <- list_of(integer()) do
          assert ConcreteOptics.Setter.Laws.over_identity(my_setter(), s)
        end

        check all s  <- list_of(integer()),
                  f  <- fn() -> integer() end,  # illustrative; use closures
                  g  <- fn() -> integer() end do
          # In practice generate concrete f and g by picking from a set of
          # known integer-to-integer functions.
          assert ConcreteOptics.Setter.Laws.over_composition(my_setter(), f, g, s)
        end

        check all s  <- list_of(integer()),
                  v1 <- integer(),
                  v2 <- integer() do
          assert ConcreteOptics.Setter.Laws.set_set(my_setter(), s, v1, v2)
        end
      end
  """

  alias ConcreteOptics.Setter

  @doc """
  **OverIdentity** — `over s id ≡ id`

  Applying `over` with the identity function leaves the structure unchanged.

  `setter.over.(fn x -> x end).(s) == s`

  Quantified over all `s : S`.
  """
  def over_identity(%Setter{} = setter, s) do
    setter.over.(fn x -> x end).(s) == s
  end

  @doc """
  **OverComposition** — `over(f ∘ g) ≡ over(f) ∘ over(g)`

  Applying `over` with a composed function is the same as applying `over` with
  each function in sequence.

  `setter.over.(fn x -> f.(g.(x)) end).(s) == setter.over.(f).(setter.over.(g).(s))`

  Quantified over all `s : S`, `f : B -> C`, `g : A -> B`.
  For the type-preserving case `A = B = C`.
  """
  def over_composition(%Setter{} = setter, f, g, s) do
    setter.over.(fn x -> f.(g.(x)) end).(s) ==
      setter.over.(f).(setter.over.(g).(s))
  end

  @doc """
  **SetSet** — `set l v' (set l v s) ≡ set l v' s`

  Setting twice in succession equals only the last set. In terms of `over`:

  `setter.over.(fn _ -> b2 end).(setter.over.(fn _ -> b1 end).(s)) == setter.over.(fn _ -> b2 end).(s)`

  Quantified over all `s : S`, `b1 : B`, `b2 : B`.
  """
  def set_set(%Setter{} = setter, s, b1, b2) do
    setter.over.(fn _ -> b2 end).(setter.over.(fn _ -> b1 end).(s)) ==
      setter.over.(fn _ -> b2 end).(s)
  end
end
