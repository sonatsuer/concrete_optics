defmodule ConcreteOptics.Lens.Laws do
  @moduledoc """
  Well-formedness laws for `ConcreteOptics.Lens`.

  A `Lens s t a b` is well-formed iff the following three laws hold.  They are
  stated in terms of the lens's `view` and `over` capabilities, where the
  Haskell function `set l v s` corresponds to `lens.over.(fn _ -> v end).(s)`.

  All three laws are quantified over the *simple* (type-preserving) case
  `s = t`, `a = b`.

  ## Laws (from optics-core well-formedness)

  - **GetPut** — `view l (set l v s) ≡ v`
  - **PutGet** — `set l (view l s) s ≡ s`
  - **PutPut** — `set l v' (set l v s) ≡ set l v' s`

  ## Usage in a property test

      property "fst_lens is well-formed" do
        check all {a, b} <- tuple({integer(), term()}),
                  v      <- integer() do
          s = {a, b}
          assert ConcreteOptics.Lens.Laws.get_put(fst_lens(), s, v)
          assert ConcreteOptics.Lens.Laws.put_get(fst_lens(), s)
        end

        check all {a, b} <- tuple({integer(), term()}),
                  v1     <- integer(),
                  v2     <- integer() do
          assert ConcreteOptics.Lens.Laws.put_put(fst_lens(), {a, b}, v1, v2)
        end
      end
  """

  alias ConcreteOptics.Lens

  @doc """
  **GetPut** — `view l (set l v s) ≡ v`

  After setting a value `b` into the structure `s`, viewing it back yields `b`.
  Expressed via `over`: `lens.view.(lens.over.(fn _ -> b end).(s)) == b`.

  Quantified over all `s : S` and `b : B`.
  """
  def get_put(%Lens{} = lens, s, b) do
    lens.view.(lens.over.(fn _ -> b end).(s)) == b
  end

  @doc """
  **PutGet** — `set l (view l s) s ≡ s`

  Setting the value we just viewed leaves the structure unchanged.
  Expressed via `over`: `lens.over.(fn x -> x end).(s) == s`.

  Quantified over all `s : S`.
  """
  def put_get(%Lens{} = lens, s) do
    lens.over.(fn x -> x end).(s) == s
  end

  @doc """
  **PutPut** — `set l v' (set l v s) ≡ set l v' s`

  Setting twice in succession is the same as only the second set.
  Expressed via `over`:
  `lens.over.(fn _ -> b2 end).(lens.over.(fn _ -> b1 end).(s)) == lens.over.(fn _ -> b2 end).(s)`.

  Quantified over all `s : S`, `b1 : B`, `b2 : B`.
  """
  def put_put(%Lens{} = lens, s, b1, b2) do
    lens.over.(fn _ -> b2 end).(lens.over.(fn _ -> b1 end).(s)) ==
      lens.over.(fn _ -> b2 end).(s)
  end
end
