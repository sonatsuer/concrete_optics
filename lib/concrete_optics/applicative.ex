defmodule ConcreteOptics.Applicative do
  @moduledoc """
  A module which defines an macro to generate types for an applicative interface.
  the macro assumes that the caller module defines a type `t/1` for the applicatives
  values and three specs for functions named `pure`, `lift1` and `lift2`.
  See `ConcreteOptics.Applicative.Id` for the specs associated to these functions.
  """

  defmacro __using__(_opts) do
    caller_module = __CALLER__.module

    quote do
      @spec pure(A) :: unquote(caller_module).t(A)
      @spec lift1((A -> B), unquote(caller_module).t(A)) :: unquote(caller_module).t(A)
      @spec lift2((A, B -> C), unquote(caller_module).t(A), unquote(caller_module).t(B)) ::
              unquote(caller_module).t(C)
    end
  end
end

defmodule ConcreteOptics.Applicative.Id do
  @moduledoc """
  The identity applicative without a wrapper. all operations are essentially noop.
  """
  @type t(a) :: a
  use ConcreteOptics.Applicative

  def pure(a) do
    a
  end

  def lift1(f, a) do
    f.(a)
  end

  def lift2(f, a, b) do
    f.(a, b)
  end
end
