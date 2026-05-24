defmodule ConcreteOptics.Getter do
  @moduledoc """
  Getter — `Getter s a`.

  A getter is a read-only optic that extracts a single element from a
  structure.  It is the simplest optic: it can only view and list, never
  modify.

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |  ✓   |    ✓    |        |      |          |

  ## Fields

  - `view`    — `s -> a`
  - `to_list` — `s -> [a]`
  """

  @enforce_keys [:view, :to_list]
  defstruct [:view, :to_list]

  @doc """
  Construct a `Getter s a` from a `view` function.

  `to_list` is derived as `fn s -> [view.(s)] end`.

  Corresponds to Haskell's `to :: (s -> a) -> Getter s a`.
  """
  def new(view) do
    %__MODULE__{
      view: view,
      to_list: fn s -> [view.(s)] end
    }
  end
end
