defmodule ConcreteOptics.Iso do
  @moduledoc """
  Isomorphism — `Iso s t a b`.

  An isomorphism represents a bidirectional, structure-preserving
  transformation between types.  It is the most capable optic: it has all
  five capabilities.

  ## Capabilities

  | view | to_list | review | over | traverse |
  |:----:|:-------:|:------:|:----:|:--------:|
  |  ✓   |    ✓    |   ✓    |  ✓   |    ✓     |

  ## Fields

  - `view`     — `s -> a`
  - `review`   — `b -> t`
  - `over`     — `(a -> b) -> (s -> t)`
  - `to_list`  — `s -> [a]`
  - `traverse` — `Applicative f -> (a -> f b) -> (s -> f t)`
  """

  @enforce_keys [:view, :review, :over, :to_list, :traverse]
  defstruct [:view, :review, :over, :to_list, :traverse]

  @doc """
  Construct an `Iso s t a b` from a `view` and a `review`.

  All other capabilities are derived:

  - `to_list s = [view(s)]`
  - `over f s = review(f(view(s)))`
  - `traverse ap f s = ap.fmap(review, f(view(s)))`

  Corresponds to Haskell's `iso :: (s -> a) -> (b -> t) -> Iso s t a b`.
  """
  def new(view, review) do
    %__MODULE__{
      view: view,
      review: review,
      to_list: fn s -> [view.(s)] end,
      over: fn f -> fn s -> s |> view.() |> f.() |> review.() end end,
      traverse: fn ap -> fn f -> fn s -> ap.fmap.(review, f.(view.(s))) end end end
    }
  end

  @doc """
  Invert an isomorphism, swapping the `view` and `review` directions.

      invert(iso s t a b) : Iso a b s t
  """
  def invert(%__MODULE__{view: v, review: r}) do
    new(r, v)
  end

  @doc """
  The identity isomorphism — `Iso s s s s`.

  `view` and `review` are both the identity function.
  """
  def identity do
    new(&Function.identity/1, &Function.identity/1)
  end

  @doc """
  Transport a function across an isomorphism (_transport of structure_).

  Given `iso : Iso s t a b` and `f : a -> b`, produces `s -> t` by going
  into the `a`-world via `view`, applying `f`, and coming back via `review`.

      transport(iso, f).(s) == iso.review.(f.(iso.view.(s)))
  """
  def transport(%__MODULE__{} = iso, f) do
    fn s -> s |> iso.view.() |> f.() |> iso.review.() end
  end
end
