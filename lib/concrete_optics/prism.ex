defmodule ConcreteOptics.Prism do
  @moduledoc """
  Prism — `Prism s t a b`.

  A prism focuses on a single constructor of a sum type (e.g., one branch of
  a tagged union).  It can construct a whole from a part (`review`) and attempt
  to match a whole to extract the part, but it cannot guarantee extraction
  (no `view`).

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |      |    ✓    |   ✓    |  ✓   |    ✓     |

  ## Fields

  - `review`   — `b -> t`
  - `over`     — `(a -> b) -> (s -> t)`
  - `to_list`  — `s -> [a]`
  - `traverse` — `Applicative f -> (a -> f b) -> (s -> f t)`
  """

  @enforce_keys [:review, :over, :to_list, :traverse]
  defstruct [:review, :over, :to_list, :traverse]

  @doc """
  Construct a `Prism s t a b` from a `review` and a `match`.

  - `review : b -> t`                       — construct the whole from the part
  - `match  : s -> {:ok, a} | {:no_match, t}` — attempt to extract the part;
    returns `{:ok, a}` on success or `{:no_match, t}` (carrying the pass-through
    value) on failure

  All other capabilities are derived:

  - `to_list s = case match(s) do {:ok, a} -> [a]; {:no_match, _} -> [] end`
  - `over f s  = case match(s) do {:ok, a} -> review(f(a)); {:no_match, t} -> t end`
  - `traverse ap f s = case match(s) do {:ok, a} -> ap.fmap(review, f(a)); {:no_match, t} -> ap.pure(t) end`

  Corresponds to Haskell's
  `prism :: (b -> t) -> (s -> Either t a) -> Prism s t a b`.
  """
  def new(review, match) do
    %__MODULE__{
      review: review,
      to_list: fn s ->
        case match.(s) do
          {:ok, a} -> [a]
          {:no_match, _} -> []
        end
      end,
      over: fn f ->
        fn s ->
          case match.(s) do
            {:ok, a} -> review.(f.(a))
            {:no_match, t} -> t
          end
        end
      end,
      traverse: fn ap ->
        fn f ->
          fn s ->
            case match.(s) do
              {:ok, a} -> ap.fmap.(review, f.(a))
              {:no_match, t} -> ap.pure.(t)
            end
          end
        end
      end
    }
  end

  @doc """
  Convenience constructor for a type-preserving prism (`s = t`, `a = b`).

  - `review : b -> s`
  - `match  : s -> {:ok, a} | :no_match`

  `:no_match` is automatically wrapped into `{:no_match, s}` so that the
  original value passes through unchanged on a miss.

  Corresponds to Haskell's
  `prism' :: (b -> s) -> (s -> Maybe a) -> Prism s s a b`.
  """
  def new_(review, match) do
    full_match = fn s ->
      case match.(s) do
        {:ok, a} -> {:ok, a}
        :no_match -> {:no_match, s}
      end
    end

    new(review, full_match)
  end
end
