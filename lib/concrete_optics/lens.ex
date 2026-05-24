defmodule ConcreteOptics.Lens do
  @moduledoc """
  Lens — `Lens s t a b`.

  A lens focuses on a single element inside a product type (e.g., a record
  field).  It can always get and always set that element, but cannot construct
  a whole value from the element alone (no `review`).

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |  ✓   |    ✓    |        |  ✓   |    ✓     |

  ## Fields

  - `view`     — `s -> a`
  - `over`     — `(a -> b) -> (s -> t)`
  - `to_list`  — `s -> [a]`
  - `traverse` — `Applicative f -> (a -> f b) -> (s -> f t)`
  """

  @enforce_keys [:view, :over, :to_list, :traverse]
  defstruct [:view, :over, :to_list, :traverse]

  @doc """
  Construct a `Lens s t a b` from a `view` and an `update`.

  - `view   : s -> a`       — extract the focused element
  - `update : s -> b -> t`  — replace the focused element in the original structure

  All other capabilities are derived:

  - `to_list s = [view(s)]`
  - `over f s = update(s, f(view(s)))`
  - `traverse ap f s = ap.fmap(b -> update(s, b), f(view(s)))`

  Corresponds to Haskell's `lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b`.
  """
  def new(view, update) do
    %__MODULE__{
      view: view,
      to_list: fn s -> [view.(s)] end,
      over: fn f -> fn s -> update.(s, f.(view.(s))) end end,
      traverse: fn ap ->
        fn f ->
          fn s ->
            ap.fmap.(fn b -> update.(s, b) end, f.(view.(s)))
          end
        end
      end
    }
  end
end
