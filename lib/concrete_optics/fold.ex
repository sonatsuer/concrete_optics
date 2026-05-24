defmodule ConcreteOptics.Fold do
  @moduledoc """
  Fold — `Fold s a`.

  A fold extracts zero or more elements from a structure, read-only.  It is
  the read-only analogue of a traversal: it can list focused elements but
  cannot modify them.

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |      |    ✓    |        |      |          |

  ## Fields

  - `to_list` — `s -> [a]`
  """

  @enforce_keys [:to_list]
  defstruct [:to_list]

  @doc """
  Construct a `Fold s a` from a function `s -> [a]`.

  Corresponds to Haskell's `folding :: Foldable f => (s -> f a) -> Fold s a`
  (specialised to lists as the foldable).
  """
  def new(to_list_fn) do
    %__MODULE__{to_list: to_list_fn}
  end
end
