defmodule ConcreteOptics.Setter do
  @moduledoc """
  Setter — `Setter s t a b`.

  A setter is a write-only optic that can modify the focused elements but
  cannot read them.  It is the dual of a getter in the read/write axis.

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |      |         |        |  ✓   |          |

  ## Fields

  - `over` — `(a -> b) -> (s -> t)`
  """

  @enforce_keys [:over]
  defstruct [:over]

  @doc """
  Construct a `Setter s t a b` from an `over` function.

  Corresponds to Haskell's `sets :: ((a -> b) -> s -> t) -> Setter s t a b`.
  """
  def new(over_fn) do
    %__MODULE__{over: over_fn}
  end
end
