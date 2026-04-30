defmodule Sandbox do
  def compose_kleisli(f, g) do
    fn x ->
      x
      |> g.()
      |> Enum.flat_map(f)
    end
  end

  def f >>> g, do: compose_kleisli(f, g)

  def apply_(f, x) do
    f.(x)
  end

  def x ||| f, do: apply_(f, x)

  def pair(n) do
    fn m ->
      [n, m]
    end
  end

  def x() do
    3 ||| pair(1) >>> pair(2)
  end
end
