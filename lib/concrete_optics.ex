defmodule ConcreteOptics do
  @moduledoc """
  Re-export module for convenience. Includes all standard optics,
  optic constructors and optic axioms.
  """

  @type optic(s, t, a, b) :: ConcreteOptics.Core.t(s, t, a, b)

  @spec compose(optic(S, T, AS, BT), optic(AS, BT, A, B)) :: optic(S, T, A, B)
  defdelegate compose(op1, op2), to: ConcreteOptics.Core

  @spec optic(S, T, AS, BT) >>> optic(AS, BT, A, B) :: optic(S, T, A, B)
  @doc """
  Infix version of optic composition
  """
  def op1 >>> op2, do: compose(op1, op2)

  @spec mk_iso((S -> A), (B -> T)) :: optic(S, T, A, B)
  defdelegate mk_iso(f, g), to: ConcreteOptics.Iso

  @spec view_review(optic(S, T, A, B)) :: (S -> bool())
  defdelegate view_review(opt), to: ConcreteOptics.Iso.Axioms

  @spec review_view(optic(S, T, A, B)) :: (S -> bool())
  defdelegate review_view(opt), to: ConcreteOptics.Iso.Axioms
end
