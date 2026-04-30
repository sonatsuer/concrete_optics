defmodule ConcreteOptics.Optics.Iso do
  @moduledoc """
  Isomorphism as an optic.
  """

  alias ConcreteOptics.Optics.Iso

  use ConcreteOptics.Core.Common, capabilities: [:view, :review, :over, :to_list, :traverse]

  @doc """
  Constructs an isomorphism from given `view` and `review` functions.
  """
  @spec new((S -> A), (B -> T)) :: t(S, T, A, B)
  def new(view, review) do
    %Iso{
      view: view,
      review: review,
      to_list: fn x -> [view.(x)] end,
      over: fn a_to_b ->
        fn s ->
          s
          |> view.()
          |> a_to_b.()
          |> review.()
        end
      end,
      traverse: fn applicative ->
        fn a_to_fb ->
          fn s ->
            s
            |> view.()
            |> a_to_fb.()
            |> (fn fb -> applicative.lift1(review, fb) end).()
          end
        end
      end
    }
  end

  @doc """
  TODO
  """
  @spec invert_iso(t(S, T, A, B)) :: t(S, T, A, B)
  def invert_iso(opt) do
    new_view = opt.review
    new_review = opt.view
    new(new_view, new_review)
  end

  defp id(x) do
    x
  end

  @doc """
  TODO
  """
  @spec eq() :: t(S, T, S, T)
  def eq do
    Iso.new(&id/1, &id/1)
  end

  @doc """
  The `transport!/2` function implements an idea known as _transport of structure_
  in universal algebra. Transporting a function means to move its implementation to a
  different type by going back and forth between the types. The first argument of
  `transport!/2` needs to be an iso. Otherwise the function throws an `ArgumentError`
  exception.
  """
  @spec transport(t(S, T, A, B), (A -> B)) :: (S -> T)
  def transport(opt, f) do
    fn x ->
       x |> opt.view.() |> f.() |> opt.review.()
    end
  end
end

defmodule ConcreteOptics.Iso.Axioms do
  @moduledoc """
  Axioms that a lawful isomorphism should satisfy. These are meant to be
  used in property tests for custom isomorphisms constructed using `ConcreteOptics.Iso.new`.
  """

  alias ConcreteOptics.Iso

  @spec review_view(Iso.t(S, T, A, B)) :: (S -> bool())
  @doc """
  The isomorphism law which states that applying review and then view yields the original value.
  """
  def review_view(optic) do
    fn x ->
      x
      |> optic.review.()
      |> optic.view.()
      |> (fn y -> x === y end).()
    end
  end

  @spec view_review(Iso.t(S, T, A, B)) :: (S -> bool())
  @doc """
  The isomorphism law which states that applying view and then review yields the original value.
  """
  def view_review(optic) do
    fn x ->
      x
      |> optic.view.()
      |> optic.review.()
      |> (fn y -> x === y end).()
    end
  end
end
