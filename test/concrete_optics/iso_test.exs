defmodule ConcreteOptics.IsoTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias ConcreteOptics.Iso.Axioms
  alias ConcreteOptics.Core

  def shift_iso do
    increase = fn
      n -> n + 1
    end

    decrease = fn
      n -> n - 1
    end

    ConcreteOptics.mk_iso(increase, decrease)
  end

  property "shift_iso is an iso" do
    check all n <- StreamData.integer(-1000..1000) do
      assert Axioms.view_review(shift_iso()).(n)
      assert Axioms.review_view(shift_iso()).(n)
    end
  end

  def composite do
    Core.compose(shift_iso(), ConcreteOptics.Iso.invert_iso!(shift_iso()))
  end

  property "Composition and inversion work for shift_iso" do
    check all n <- StreamData.integer(-1000..1000) do
      assert composite().view.(n) === n, "view should be id"
      assert composite().review.(n) === n, "review should be id"
    end
  end
end
