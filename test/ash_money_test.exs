defmodule AshMoneyTest do
  use ExUnit.Case
  doctest AshMoney

  defmodule ExampleResource do
    use Ash.Resource, domain: nil

    attributes do
      uuid_primary_key(:id)
      attribute(:frozen_from, :date)
      attribute(:frozen_until, :date)
      attribute(:end_date, :date)

      attribute :visit_status, :atom do
        constraints(one_of: [:scheduled])
      end

      attribute(:scheduled_date, :date)

      attribute :latest_report_state, :atom do
        constraints(one_of: [:pending])
      end

      attribute(:duration, :decimal)

      attribute(:amount, AshMoney.Types.Money)
    end
  end

  import Ash.Expr

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
           ) ==
             {[
                {AshMoney.Types.Money, [storage_type: :money_with_currency]},
                {Ash.Type.Decimal, []}
              ], {Ash.Type.Boolean, []}}
  end

  test "type overrides detect mixed types" do
    {:ok, %op{left: left, right: right}} =
      expr(amount <= 10)
      |> Ash.Filter.hydrate_refs(%{resource: ExampleResource})

    assert determine_types(op, [left, right], :boolean) ==
             {[
                {AshMoney.Types.Money, [storage_type: :money_with_currency]},
                {Ash.Type.Decimal, []}
              ], {Ash.Type.Boolean, []}}
  end

  test "composite types can be accessed" do
    assert {:ok, expr} =
             expr(amount[:currency])
             |> Ash.Filter.hydrate_refs(%{resource: ExampleResource})

    assert {:ok, :USD} = eval(expr, record: %ExampleResource{amount: Money.new(0, :USD)})
  end
end
