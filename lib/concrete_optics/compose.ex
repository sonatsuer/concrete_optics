defmodule ConcreteOptics.Compose do
  @moduledoc """
  Composition of two optics.

  `compose(o1, o2)` composes `o1 : Optic s t a' b'` with `o2 : Optic a' b' a b`
  to produce `Optic s t a b`.  The result type is determined by the intersection
  of the two optics' capabilities:

  | o1 \\ o2  | Iso       | Lens      | Prism     | Traversal | Getter | Setter | Fold |
  |-----------|-----------|-----------|-----------|-----------|--------|--------|------|
  | Iso       | Iso       | Lens      | Prism     | Traversal | Getter | Setter | Fold |
  | Lens      | Lens      | Lens      | Traversal | Traversal | Getter | Setter | Fold |
  | Prism     | Prism     | Traversal | Prism     | Traversal | Fold   | Setter | Fold |
  | Traversal | Traversal | Traversal | Traversal | Traversal | Fold   | Setter | Fold |
  | Getter    | Getter    | Getter    | Fold      | Fold      | Getter | ✗      | Fold |
  | Setter    | Setter    | Setter    | Setter    | Setter    | ✗      | Setter | ✗    |
  | Fold      | Fold      | Fold      | Fold      | Fold      | Fold   | ✗      | Fold |

  ✗ = raises `ArgumentError` (no common capabilities).

  Use `compose_all/1` to compose a list of optics left-to-right.
  """

  import ConcreteOptics.Capabilities

  alias ConcreteOptics.Iso
  alias ConcreteOptics.Lens
  alias ConcreteOptics.Prism
  alias ConcreteOptics.Traversal
  alias ConcreteOptics.Getter
  alias ConcreteOptics.Setter
  alias ConcreteOptics.Fold

  # ---------------------------------------------------------------------------
  # Iso ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Iso{} = o1, %Iso{} = o2) do
    %Iso{
      view: compose_view(o1.view, o2.view),
      review: compose_review(o1.review, o2.review),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Iso{} = o1, %Lens{} = o2) do
    %Lens{
      view: compose_view(o1.view, o2.view),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Iso{} = o1, %Prism{} = o2) do
    %Prism{
      review: compose_review(o1.review, o2.review),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Iso{} = o1, %Traversal{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Iso{} = o1, %Getter{} = o2) do
    %Getter{
      view: compose_view(o1.view, o2.view),
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Iso{} = o1, %Setter{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Iso{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # Lens ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Lens{} = o1, %Iso{} = o2) do
    %Lens{
      view: compose_view(o1.view, o2.view),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Lens{} = o1, %Lens{} = o2) do
    %Lens{
      view: compose_view(o1.view, o2.view),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Lens{} = o1, %Prism{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Lens{} = o1, %Traversal{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Lens{} = o1, %Getter{} = o2) do
    %Getter{
      view: compose_view(o1.view, o2.view),
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Lens{} = o1, %Setter{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Lens{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # Prism ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Prism{} = o1, %Iso{} = o2) do
    %Prism{
      review: compose_review(o1.review, o2.review),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Prism{} = o1, %Lens{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Prism{} = o1, %Prism{} = o2) do
    %Prism{
      review: compose_review(o1.review, o2.review),
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Prism{} = o1, %Traversal{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Prism{} = o1, %Getter{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Prism{} = o1, %Setter{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Prism{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # Traversal ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Traversal{} = o1, %Iso{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Traversal{} = o1, %Lens{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Traversal{} = o1, %Prism{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Traversal{} = o1, %Traversal{} = o2) do
    %Traversal{
      over: compose_over(o1.over, o2.over),
      to_list: compose_to_list(o1.to_list, o2.to_list),
      traverse: compose_traverse(o1.traverse, o2.traverse)
    }
  end

  def compose(%Traversal{} = o1, %Getter{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Traversal{} = o1, %Setter{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Traversal{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # Getter ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Getter{} = o1, %Iso{} = o2) do
    %Getter{
      view: compose_view(o1.view, o2.view),
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Getter{} = o1, %Lens{} = o2) do
    %Getter{
      view: compose_view(o1.view, o2.view),
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Getter{} = o1, %Prism{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Getter{} = o1, %Traversal{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Getter{} = o1, %Getter{} = o2) do
    %Getter{
      view: compose_view(o1.view, o2.view),
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Getter{}, %Setter{}) do
    raise ArgumentError,
          "Cannot compose a Getter with a Setter: they share no common capabilities."
  end

  def compose(%Getter{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # Setter ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Setter{} = o1, %Iso{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Setter{} = o1, %Lens{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Setter{} = o1, %Prism{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Setter{} = o1, %Traversal{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Setter{}, %Getter{}) do
    raise ArgumentError,
          "Cannot compose a Setter with a Getter: they share no common capabilities."
  end

  def compose(%Setter{} = o1, %Setter{} = o2) do
    %Setter{
      over: compose_over(o1.over, o2.over)
    }
  end

  def compose(%Setter{}, %Fold{}) do
    raise ArgumentError,
          "Cannot compose a Setter with a Fold: they share no common capabilities."
  end

  # ---------------------------------------------------------------------------
  # Fold ∘ _
  # ---------------------------------------------------------------------------

  def compose(%Fold{} = o1, %Iso{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Fold{} = o1, %Lens{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Fold{} = o1, %Prism{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Fold{} = o1, %Traversal{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Fold{} = o1, %Getter{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  def compose(%Fold{}, %Setter{}) do
    raise ArgumentError,
          "Cannot compose a Fold with a Setter: they share no common capabilities."
  end

  def compose(%Fold{} = o1, %Fold{} = o2) do
    %Fold{
      to_list: compose_to_list(o1.to_list, o2.to_list)
    }
  end

  # ---------------------------------------------------------------------------
  # compose_all
  # ---------------------------------------------------------------------------

  @doc """
  Compose a non-empty list of optics left-to-right.

      compose_all([o1, o2, o3]) == compose(compose(o1, o2), o3)

  Raises `ArgumentError` if the list is empty or if any adjacent pair has no
  common capabilities.
  """
  def compose_all([single]), do: single
  def compose_all([h | t]), do: Enum.reduce(t, h, fn o2, o1 -> compose(o1, o2) end)
  def compose_all([]), do: raise(ArgumentError, "compose_all requires a non-empty list")
end
