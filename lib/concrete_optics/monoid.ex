defmodule ConcreteOptics.Monoid do
  @moduledoc """
  A monoid record.

  A monoid `m` is a set equipped with an identity element and an associative
  binary operation:

      combine(unit, x) == x
      combine(x, unit) == x
      combine(combine(x, y), z) == combine(x, combine(y, z))

  ## Fields

  - `unit`    — `m`           — the identity element
  - `combine` — `m -> m -> m` — the associative binary operation
  """

  @enforce_keys [:unit, :combine]
  defstruct [:unit, :combine]

  @doc """
  The list monoid — unit is `[]`, combine is `++`.
  """
  def list_monoid do
    %__MODULE__{
      unit: [],
      combine: fn a, b -> a ++ b end
    }
  end
end
