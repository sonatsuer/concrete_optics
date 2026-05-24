defmodule ConcreteOptics.Capabilities do
  @moduledoc """
  The five primitive capability-composition functions.

  All composition assumes the type-alignment:

      Optic s t a' b'   composed with   Optic a' b' a b   gives   Optic s t a b

  Each function takes the capability from the *outer* optic first, then the
  *inner* optic, matching that left-to-right ordering.
  """

  @doc """
  Compose two `view` capabilities.

  `view1 : s -> a'`  and  `view2 : a' -> a`  give  `s -> a`.
  This is ordinary forward function composition.
  """
  def compose_view(view1, view2) do
    fn s -> view2.(view1.(s)) end
  end

  @doc """
  Compose two `review` capabilities.

  `review1 : b' -> t`  and  `review2 : b -> b'`  give  `b -> t`.
  This is backward (reversed) function composition.
  """
  def compose_review(review1, review2) do
    fn b -> review1.(review2.(b)) end
  end

  @doc """
  Compose two `over` capabilities.

  `over1 : (a' -> b') -> (s -> t)`  and  `over2 : (a -> b) -> (a' -> b')`
  give  `(a -> b) -> (s -> t)`.
  This is forward composition (over₁ ∘ over₂).
  """
  def compose_over(over1, over2) do
    fn f -> over1.(over2.(f)) end
  end

  @doc """
  Compose two `to_list` capabilities.

  `to_list1 : s -> [a']`  and  `to_list2 : a' -> [a]`  give  `s -> [a]`.
  This is Kleisli composition in the list monad (`flat_map`).
  """
  def compose_to_list(to_list1, to_list2) do
    fn s -> to_list1.(s) |> Enum.flat_map(to_list2) end
  end

  @doc """
  Compose two `traverse` capabilities.

  `traverse1 : ap -> (a' -> f b') -> (s -> f t)`  and
  `traverse2 : ap -> (a -> f b) -> (a' -> f b')`  give
  `ap -> (a -> f b) -> (s -> f t)`.

  This is composition in the reader monad where the shared context is the
  applicative `ap`.
  """
  def compose_traverse(traverse1, traverse2) do
    fn ap -> fn f -> traverse1.(ap).(traverse2.(ap).(f)) end end
  end
end
