defmodule ConcreteOptics.Core.Capabilities do
  @moduledoc """
  TODO
  Optic s t sa tb -> Optic sa tb a b -> Optic s t a b
  """

  # ---------------------------------
  # Private helpers

  # Composition in the "ambient category".
  defp compose_forward(f, g), do: fn x -> f.(g.(x)) end

  # Composition in the opposite category.
  defp compose_backward(f, g), do: fn x -> g.(f.(x)) end

  # Composition in the Kleisli category of lists.
  defp compose_kleisli(f, g),
    do: fn x ->
      x
      |> g.()
      |> Enum.flat_map(f)
    end

  # Function Composition lifted to a Reader monad.
  defp compose_reader(f, g) do
    fn r ->
      compose_forward(f.(r), g.(r))
    end
  end

  # ---------------------------------
  # view

  @typedoc """
  TODO
  """
  @type view_t(s, a) :: (s -> a)

  @doc """
  TODO
  """
  @spec compose_view(view_t(S, SA), view_t(SA, A)) :: view_t(S, A)
  def compose_view(view1, view2) do
    compose_forward(view1, view2)
  end


  @typedoc """
  TODO
  """
  @type review_t(t, b) :: (b -> t)

  # ---------------------------------
  # review

  @doc """
  TODO
  """
  @spec compose_review(review_t(T, TB), review_t(TB, B)) :: review_t(T, B)
  def compose_review(review1, review2) do
    compose_backward(review1, review2)
  end


  # ---------------------------------
  # over

  @typedoc """
  TODO
  """
  @type over_t(s, t, a, b) :: ((a -> b) -> (s -> t))
  @doc """

  TODO
  """
  @spec compose_over(over_t(S, T, SA, TB), over_t(SA, TB, A, B)) :: over_t(S, T, A, B)
  def compose_over(over1, over2) do
    compose_forward(over1, over2)
  end

  # ---------------------------------
  # to_list

  @typedoc """
  TODO
  """
  @type to_list_t(s, a) :: (s -> [a])


  @doc """
  TODO
  """
  @spec compose_to_list(to_list_t(S, SA), to_list_t(SA, A)) :: to_list_t(S, A)
  def compose_to_list(to_list1, to_list2) do
    compose_kleisli(to_list1, to_list2)
  end


  # ---------------------------------
  # to_traverse

  @typedoc """
  TODO
  """
  @type traverse_t(s, a) :: (module() -> ((a -> any()) -> (s -> any())) )

  @doc """
  TODO
  """
  @spec compose_traverse(traverse_t(S, SA), traverse_t(SA,  A)) :: traverse_t(S, A)
  def compose_traverse(traverse1, traverse2) do
    compose_reader(traverse1, traverse2)
  end
end
