if Code.ensure_loaded?(AshPostgres.CustomExtension) do
  defmodule AshMoney.AshPostgresExtension do
    @moduledoc """
    Installs the `money_with_currency` type and operators/functions for Postgres.
    """
    use AshPostgres.CustomExtension, name: :ash_money, latest_version: 2

    def install(1) do
      """
      #{Money.DDL.execute_each(add_money_mult())}
      """
    end

    def install(0) do
      """
      #{Money.DDL.execute_each(Money.DDL.create_money_with_currency())}
      #{Money.DDL.execute_each(Money.DDL.define_plus_operator())}
      #{Money.DDL.execute_each(Money.DDL.define_minmax_functions())}
      #{Money.DDL.execute_each(Money.DDL.define_sum_function())}
      #{Money.DDL.execute_each(add_money_mult())}
      """
    end

    def uninstall(v) when v in [0, 1, 2] do
      """
      #{Money.DDL.execute_each(remove_money_mult())}
      #{Money.DDL.execute_each(Money.DDL.drop_sum_function())}
      #{Money.DDL.execute_each(Money.DDL.drop_minmax_functions())}
      #{Money.DDL.execute_each(Money.DDL.drop_plus_operator())}
      #{Money.DDL.execute_each(Money.DDL.drop_money_with_currency())}
      """
    end

    defp add_money_mult do
      """
      CREATE OR REPLACE FUNCTION money_mult(multiplicator numeric, money money_with_currency)
      RETURNS money_with_currency
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          multiplication numeric;
        BEGIN
            currency := currency_code(money);
            multiplication := amount(money) * multiplicator;
            return row(currency, multiplication);
        END;
      $$;


      CREATE OR REPLACE FUNCTION money_mult_reverse(money money_with_currency, multiplicator numeric)
      RETURNS money_with_currency
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
      BEGIN
          RETURN money_mult(multiplicator, money);
      END;
      $$;


      CREATE OPERATOR * (
          LEFTARG = numeric,
          RIGHTARG = money_with_currency,
          PROCEDURE = money_mult
      );


      CREATE OPERATOR * (
          LEFTARG = money_with_currency,
          RIGHTARG = numeric,
          PROCEDURE = money_mult_reverse
      );
      """
    end

    defp remove_money_mult do
      """
      DROP OPERATOR * (money_with_currency, numeric);


      DROP OPERATOR * (numeric, money_with_currency);


      DROP FUNCTION IF EXISTS money_mult(multiplicator numeric, money money_with_currency);


      DROP FUNCTION IF EXISTS money_mult(money money_with_currency, multiplicator numeric);
      """
    end
  end
end
