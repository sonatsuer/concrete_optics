defmodule ConcreteOptics.Iso.Laws do
  @moduledoc """
  Well-formedness laws for `ConcreteOptics.Iso`.

  An `Iso s t a b` is well-formed iff `view` and `review` are mutually inverse.
  Because type parameters in Elixir are not yet supported at the language level,
  both laws are stated for the *simple* (type-preserving) case where `s = t` and
  `a = b`. A full type-changing iso would require two separate round-trip laws
  in each direction.

  ## Usage in a property test

      property "my_iso is a valid isomorphism on the S side" do
        check all s <- my_s_generator() do
          assert ConcreteOptics.Iso.Laws.review_then_view(my_iso(), s)
        end
      end

      property "my_iso is a valid isomorphism on the A side" do
        check all a <- my_a_generator() do
          assert ConcreteOptics.Iso.Laws.view_then_review(my_iso(), a)
        end
      end
  """

  alias ConcreteOptics.Iso

  @doc """
  **ReviewThenView** — `review(view(s)) ≡ s`

  Going from `s` to `a` via `view` and back via `review` must yield the
  original `s`. Quantified over all `s : S`.
  """
  def review_then_view(%Iso{} = iso, s) do
    iso.review.(iso.view.(s)) == s
  end

  @doc """
  **ViewThenReview** — `view(review(a)) ≡ a`

  Going from `a` to `s` via `review` and back via `view` must yield the
  original `a`. Quantified over all `a : A`.
  """
  def view_then_review(%Iso{} = iso, a) do
    iso.view.(iso.review.(a)) == a
  end
end
