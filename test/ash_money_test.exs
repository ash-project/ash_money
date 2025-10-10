# SPDX-FileCopyrightText: 2020 Zach Daniel
#
# SPDX-License-Identifier: MIT

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
      attribute(:name, :string)

      attribute :visit_status, :atom do
        constraints(one_of: [:scheduled])
      end

      attribute(:scheduled_date, :date)

      attribute :latest_report_state, :atom do
        constraints(one_of: [:pending])
      end

      attribute(:duration, :decimal)

      attribute(:amount, AshMoney.Types.Money)

      attribute :amount_with_options, AshMoney.Types.Money do
        constraints(
          ex_money_opts: [
            no_fraction_if_integer: true,
            format: :short
          ]
        )

        public?(true)
      end
    end
  end

  import Ash.Expr

  describe "`ex_money_opts` constraints are applied for all cast_input/2" do
    test "with %Money{} struct" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_input(Money.new(:USD, 0), attribute.constraints)

      assert actual_output == expected_output
    end

    test "with tuple" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_input({:USD, 0}, attribute.constraints)

      assert actual_output == expected_output
    end

    test "atom key map" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_input(%{amount: 0, currency: "USD"}, attribute.constraints)

      assert actual_output == expected_output
    end

    test "string key map" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_input(
          %{"amount" => 0, "currency" => "USD"},
          attribute.constraints
        )

      assert actual_output == expected_output
    end
  end

  describe "`ex_money_opts` constraints are applied for all cast_stored/2" do
    test "with %Money{} struct" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_stored(Money.new(:USD, 0), attribute.constraints)

      assert actual_output == expected_output
    end

    test "with tuple" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_stored({"USD", 0}, attribute.constraints)

      assert actual_output == expected_output
    end

    test "string key map" do
      expected_output = Money.new(:USD, 0, no_fraction_if_integer: true, format: :short)

      attribute = Ash.Resource.Info.attribute(ExampleResource, :amount_with_options)

      {:ok, actual_output} =
        AshMoney.Types.Money.cast_stored(
          %{"amount" => 0, "currency" => "USD"},
          attribute.constraints
        )

      assert actual_output == expected_output
    end
  end

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

  @tag :regression
  test "type overrides aren't too eagerly applied" do
    {:ok, %op{left: left, right: right}} =
      expr(string_length(name) <= 10)
      |> Ash.Filter.hydrate_refs(%{resource: ExampleResource})

    assert determine_types(op, [left, right], :boolean) ==
             {[
                {Ash.Type.Integer, []},
                {Ash.Type.Integer, []}
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
