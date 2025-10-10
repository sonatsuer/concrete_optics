defmodule ConcreteOptics.Iso do
  @moduledoc """
  Isomorphism as an optic.
  """
  alias ConcreteOptics.Core

  @doc """
  Constructs an isomorphism from given `view` and `review` functions.
  """
  @spec mk_iso((S -> A), (B -> T)) :: Core.t(S, T, A, B)
  def mk_iso(view, review) do
    %Core{
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

  defp id(x) do
    x
  end

  @doc """
  This function reverses an iso by swapping `review` and `view`. If the provided
  optic is not an iso the function raises an `ArgumentError` exception.
  """
  @spec invert_iso!(Core.t(S, T, A, B)) :: Core.t(S, T, A, B)
  def invert_iso!(opt) do
    optic_type = Core.classify(opt)
    if optic_type != :iso do
      raise ArgumentError, message: "{Cannot invert #{Atom.to_string(optic_type)}. Only isos can be inverted"
    else
      new_view = opt.review
      new_review = opt.view
      mk_iso(new_view, new_review)
    end
  end

  @doc """
  The unit optic under optic composition. It is the unit among _all_ optics,
  not just among isomorphisms.
  """
  @spec eq() :: Core.t(S, T, S, T)
  def eq do
    ConcreteOptics.Iso.mk_iso(&id/1, &id/1)
  end

  @doc """
  The `transport!/2` function implements an idea known as _transport of structure_
  in universal algebra. Transporting a function means to move its implementation to a
  different type by going back and forth between the types. The first argument of
  `transport!/2` needs to be an iso. Otherwise the function throws an `ArgumentError`
  exception.
  """
  @spec transport!(Core.t(S, T, A, B), (A -> B)) :: (S -> T)
  def transport!(opt, f) do
    optic_type = Core.classify(opt)
    if optic_type != :iso do
      raise ArgumentError, message: "{Cannot transport via #{Atom.to_string(optic_type)}. Only isos allow transport."
    else
      fn x ->
         x |> opt.view.() |> f.() |> opt.review.()
      end
    end
  end
end

defmodule ConcreteOptics.Iso.Axioms do
  @moduledoc """
  Axioms that a lawful isomorphism should satisfy. These are meant to be
  used in property tests for custom isomorphisms constructed using `ConcreteOptics.Iso.mk_iso`.
  """

  alias ConcreteOptics.Core

  @spec review_view(Core.t(S, T, A, B)) :: (S -> bool())
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

  @spec view_review(Core.t(S, T, A, B)) :: (S -> bool())
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
