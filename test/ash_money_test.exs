defmodule AshMoneyTest do
  use ExUnit.Case
  use ExUnitProperties
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

  describe "min/max constraints" do
    test "accepts value within min and max range" do
      constraints = [min: Decimal.new("10"), max: Decimal.new("100")]
      money = Money.new(:USD, 50)

      {:ok, casted} = AshMoney.Types.Money.cast_input(money, constraints)
      assert {:ok, ^money} = AshMoney.Types.Money.apply_constraints(casted, constraints)
    end

    test "accepts value equal to min" do
      constraints = [min: Decimal.new("10")]
      money = Money.new(:USD, 10)

      {:ok, casted} = AshMoney.Types.Money.cast_input(money, constraints)
      assert {:ok, ^money} = AshMoney.Types.Money.apply_constraints(casted, constraints)
    end

    test "accepts value equal to max" do
      constraints = [max: Decimal.new("100")]
      money = Money.new(:USD, 100)

      {:ok, casted} = AshMoney.Types.Money.cast_input(money, constraints)
      assert {:ok, ^money} = AshMoney.Types.Money.apply_constraints(casted, constraints)
    end

    test "rejects value below min" do
      constraints = [min: Decimal.new("10")]
      money = Money.new(:USD, 5)

      {:ok, casted} = AshMoney.Types.Money.cast_input(money, constraints)

      assert {:error, [[message: message, min: min]]} =
               AshMoney.Types.Money.apply_constraints(casted, constraints)

      assert message == "must be more than or equal to %{min}"
      assert min == Decimal.new("10")
    end

    test "rejects value above max" do
      constraints = [max: Decimal.new("100")]
      money = Money.new(:USD, 150)

      {:ok, casted} = AshMoney.Types.Money.cast_input(money, constraints)

      assert {:error, [[message: message, max: max]]} =
               AshMoney.Types.Money.apply_constraints(casted, constraints)

      assert message == "must be less than or equal to %{max}"
      assert max == Decimal.new("100")
    end

    test "rejects value outside min/max range" do
      constraints = [min: Decimal.new("10"), max: Decimal.new("100")]
      money_too_low = Money.new(:USD, 5)
      money_too_high = Money.new(:USD, 150)

      {:ok, casted_low} = AshMoney.Types.Money.cast_input(money_too_low, constraints)
      {:ok, casted_high} = AshMoney.Types.Money.cast_input(money_too_high, constraints)

      assert {:error, [[message: _, min: _]]} =
               AshMoney.Types.Money.apply_constraints(casted_low, constraints)

      assert {:error, [[message: _, max: _]]} =
               AshMoney.Types.Money.apply_constraints(casted_high, constraints)
    end

    test "works with different input formats" do
      constraints = [min: Decimal.new("10"), max: Decimal.new("100")]

      # Test with tuple
      {:ok, casted_tuple_valid} = AshMoney.Types.Money.cast_input({:USD, 50}, constraints)
      assert {:ok, _} = AshMoney.Types.Money.apply_constraints(casted_tuple_valid, constraints)

      {:ok, casted_tuple_invalid} = AshMoney.Types.Money.cast_input({:USD, 5}, constraints)
      assert {:error, _} = AshMoney.Types.Money.apply_constraints(casted_tuple_invalid, constraints)

      # Test with map
      {:ok, casted_map_valid} =
        AshMoney.Types.Money.cast_input(%{"amount" => 50, "currency" => "USD"}, constraints)

      assert {:ok, _} = AshMoney.Types.Money.apply_constraints(casted_map_valid, constraints)

      {:ok, casted_map_invalid} =
        AshMoney.Types.Money.cast_input(%{"amount" => 5, "currency" => "USD"}, constraints)

      assert {:error, _} = AshMoney.Types.Money.apply_constraints(casted_map_invalid, constraints)
    end

    test "nil values bypass constraints" do
      constraints = [min: Decimal.new("10"), max: Decimal.new("100")]

      assert {:ok, nil} = AshMoney.Types.Money.cast_input(nil, constraints)
    end

    test "works with negative min values" do
      constraints = [min: Decimal.new("-100")]
      money_valid = Money.new(:USD, -50)
      money_invalid = Money.new(:USD, -150)

      {:ok, casted_valid} = AshMoney.Types.Money.cast_input(money_valid, constraints)
      assert {:ok, ^money_valid} = AshMoney.Types.Money.apply_constraints(casted_valid, constraints)

      {:ok, casted_invalid} = AshMoney.Types.Money.cast_input(money_invalid, constraints)
      assert {:error, _} = AshMoney.Types.Money.apply_constraints(casted_invalid, constraints)
    end

    test "works with negative min and max values" do
      constraints = [min: Decimal.new("-100"), max: Decimal.new("-10")]
      money_valid = Money.new(:USD, -50)
      money_too_low = Money.new(:USD, -150)
      money_too_high = Money.new(:USD, 0)

      {:ok, casted_valid} = AshMoney.Types.Money.cast_input(money_valid, constraints)
      assert {:ok, ^money_valid} = AshMoney.Types.Money.apply_constraints(casted_valid, constraints)

      {:ok, casted_too_low} = AshMoney.Types.Money.cast_input(money_too_low, constraints)
      assert {:error, [[message: _, min: _]]} =
               AshMoney.Types.Money.apply_constraints(casted_too_low, constraints)

      {:ok, casted_too_high} = AshMoney.Types.Money.cast_input(money_too_high, constraints)
      assert {:error, [[message: _, max: _]]} =
               AshMoney.Types.Money.apply_constraints(casted_too_high, constraints)
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

  describe "generator/1" do
    test "generates valid Money structs" do
      check all(
              money <- AshMoney.Types.Money.generator([]),
              max_runs: 50
            ) do
        assert %Money{} = money
        assert is_atom(money.currency)
        assert %Decimal{} = money.amount
      end
    end

    test "generator works with Ash.Seed" do
      # Verify that generated money values can be cast
      check all(
              money <- AshMoney.Types.Money.generator([]),
              max_runs: 20
            ) do
        {:ok, casted} = AshMoney.Types.Money.cast_input(money, [])
        assert %Money{} = casted
      end
    end

    test "generator respects currencies constraint" do
      check all(
              money <- AshMoney.Types.Money.generator(currencies: [:USD, :EUR, :GBP]),
              max_runs: 30
            ) do
        assert money.currency in [:USD, :EUR, :GBP]
      end
    end

    test "generator respects min constraint" do
      min = Decimal.new("10")

      check all(
              money <- AshMoney.Types.Money.generator(min: min),
              max_runs: 30
            ) do
        assert Decimal.compare(money.amount, min) != :lt
      end
    end

    test "generator respects max constraint" do
      max = Decimal.new("100")

      check all(
              money <- AshMoney.Types.Money.generator(max: max),
              max_runs: 30
            ) do
        assert Decimal.compare(money.amount, max) != :gt
      end
    end

    test "generator respects min and max constraints together" do
      min = Decimal.new("50")
      max = Decimal.new("200")

      check all(
              money <- AshMoney.Types.Money.generator(min: min, max: max),
              max_runs: 30
            ) do
        assert Decimal.compare(money.amount, min) != :lt
        assert Decimal.compare(money.amount, max) != :gt
      end
    end

    test "generator respects all constraints together" do
      check all(
              money <-
                AshMoney.Types.Money.generator(
                  currencies: [:JPY, :USD],
                  min: 1000,
                  max: 5000
                ),
              max_runs: 30
            ) do
        assert money.currency in [:JPY, :USD]
        assert Decimal.compare(money.amount, Decimal.new("1000")) != :lt
        assert Decimal.compare(money.amount, Decimal.new("5000")) != :gt
      end
    end

    test "generator works with negative min constraint" do
      min = Decimal.new("-100")

      check all(
              money <- AshMoney.Types.Money.generator(min: min),
              max_runs: 30
            ) do
        assert Decimal.compare(money.amount, min) != :lt
      end
    end

    test "generator works with negative min and max constraints" do
      min = Decimal.new("-100")
      max = Decimal.new("-10")

      check all(
              money <- AshMoney.Types.Money.generator(min: min, max: max),
              max_runs: 30
            ) do
        assert Decimal.compare(money.amount, min) != :lt
        assert Decimal.compare(money.amount, max) != :gt
      end
    end
  end
end
