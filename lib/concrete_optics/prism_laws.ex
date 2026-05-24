defmodule ConcreteOptics.Prism.Laws do
  @moduledoc """
  Well-formedness laws for `ConcreteOptics.Prism`.

  A `Prism s t a b` is well-formed iff `review` and matching are mutually
  consistent. The Haskell optics-core library states these laws as:

  1. `matching o (review o b) ≡ Right b`
  2. `matching o s ≡ Right a  ⟹  review o a ≡ s`

  In our library `matching` is not stored directly; it is absorbed into the
  derived capabilities. However both laws have clean equivalents:

  - Law 1 is equivalent to `prism.to_list.(prism.review.(b)) == [b]`:
    anything we build with `review` must be matched successfully.
  - Law 2 is equivalent to `prism.over.(fn x -> x end).(s) == s`:
    `over(id)` expands to `review(a)` on a match and to the pass-through `t`
    on a miss, so equality with `s` captures both halves of law 2 at once.

  ## Usage in a property test

      property "ok_prism is well-formed" do
        check all v <- integer() do
          assert ConcreteOptics.Prism.Laws.review_then_match(ok_prism(), v)
        end

        check all s <- one_of([tuple({constant(:ok), integer()}),
                                tuple({constant(:error), term()})]) do
          assert ConcreteOptics.Prism.Laws.match_then_review(ok_prism(), s)
        end
      end
  """

  alias ConcreteOptics.Prism

  @doc """
  **ReviewThenMatch** — `matching o (review o b) ≡ Right b`

  Constructing a whole with `review` and then attempting to match it must
  always succeed and recover the original `b`.

  Expressed via `to_list`: `prism.to_list.(prism.review.(b)) == [b]`.

  Quantified over all `b : B`.
  """
  def review_then_match(%Prism{} = prism, b) do
    prism.to_list.(prism.review.(b)) == [b]
  end

  @doc """
  **MatchThenReview** — `matching o s ≡ Right a  ⟹  review o a ≡ s`

  If matching succeeds, reviewing the extracted value gives back the original
  structure. If matching fails, the pass-through value equals the original.

  Expressed via `over`: `prism.over.(fn x -> x end).(s) == s`.

  Quantified over all `s : S`.
  """
  def match_then_review(%Prism{} = prism, s) do
    prism.over.(fn x -> x end).(s) == s
  end
end
