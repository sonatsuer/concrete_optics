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
      traverse: fn appl ->
        fn a_to_fb ->
          fn s ->
            s
            |> view.()
            |> a_to_fb.()
            |> (fn fb -> appl.lift1(review, fb) end).()
          end
        end
      end
    }
  end

  defp id(x) do
    x
  end

  @doc """
  The unit optic under optic composition.
  """
  @spec eq() ::  Core.t(S, T, S, T)
  def eq do
    ConcreteOptics.Iso.mk_iso(&id/1, &id/1)
  end
end
