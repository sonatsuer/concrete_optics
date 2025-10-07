defmodule ConcreteOptics.Core do
  @moduledoc """
  Core structure carrying the optic capabilities and basic functionality around it.
  """

  defstruct [:view, :review, :over, :to_list, :traverse]

  @typep s :: any()
  @typep t :: any()
  @typep a :: any()
  @typep b :: any()
  @typep as :: any()
  @typep bt :: any()

  @type tp(s, t, a, b) :: %__MODULE__{
    view: (s -> a) | nil,
    review: (b -> t) | nil,
    over: ((a -> b) -> (s -> t)),
    to_list: (s -> [a]),
    traverse: ((a -> any()) -> (s -> any()))
  }

  @typedoc "Complete list of supported optics."
  @type optics :: :iso | :lens | :prism | :traversal

  @doc """
  Determines the type of a lawful optic by inspecting which capabilities it has.
  """
  @spec classify(tp(s, t, a, b)) :: optics
  def classify(opt) do
    case %{view_exists: !is_nil(opt.view), review_exists: !is_nil(opt.review)} do
      %{view_exists: true, review_exists: true} -> :iso
      %{view_exists: true, review_exists: false} -> :lens
      %{view_exists: false, review_exists: true} -> :prism
      %{view_exists: false, review_exists: false} -> :traversal
    end
  end

  defp compose_forward(f, g), do:
    fn x -> f.(g.(x))
  end

  defp compose_backward(f, g), do:
    fn x -> g.(f.(x))
  end

  defp compose_kleisli(f, g), do:
    fn x ->
      x
      |> g.()
      |> Enum.flat_map(f)
  end

  defp fail_on_nil(op, x, y) do
    if is_nil(x) || is_nil(y) do
      nil
    else
      op.(x, y)
    end
  end

  @doc """
  General optic composition.
  """
  @spec compose(tp(s, t, as, bt), tp(as, bt, a, b)) :: tp(s, t, a, b)
  def compose(op1, op2) do
    %__MODULE__{
      view: fail_on_nil(&compose_forward/2, op1.view, op2.view),
      review: fail_on_nil(&compose_backward/2, op1.review, op2.review),
      over: fail_on_nil(&compose_forward/2, op1.over, op2.over),
      to_list: fail_on_nil(&compose_kleisli/2, op1.to_list, op2.to_list),
      traverse: fail_on_nil(&compose_forward/2, op1.traverse, op2.traverse)
    }
  end
end
