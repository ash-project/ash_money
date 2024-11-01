defmodule AshMoneyTest do
  use ExUnit.Case
  doctest AshMoney

  test "type overrides correctly apply" do
    assert Ash.Expr.determine_types(
             Ash.Query.Operator.LessThan,
             [
               %Ash.Query.Function.Type{
                 arguments: [
                   Money.new(0, :XSH),
                   AshMoney.Types.Money,
                   [
                     storage_type: :money_with_currency
                   ]
                 ]
               },
               0
             ],
             :boolean
           ) == {[{AshMoney.Types.Money, []}, {:integer, []}], {Ash.Type.Boolean, []}}
  end
end
