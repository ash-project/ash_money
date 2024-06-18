if Code.ensure_loaded?(AshPostgres.CustomExtension) do
  defmodule AshMoney.AshPostgresExtension do
    @moduledoc """
    Installs the `money_with_currency` type and operators/functions for Postgres.
    """
    use AshPostgres.CustomExtension, name: :ash_money, latest_version: 4

    def install(3) do
      """
      #{Money.DDL.execute_each(add_money_greater_than())}
      #{Money.DDL.execute_each(add_money_greater_than_or_equal())}
      #{Money.DDL.execute_each(add_money_less_than())}
      #{Money.DDL.execute_each(add_money_less_than_or_equal())}
      """
    end

    def install(2) do
      """
      #{Money.DDL.execute_each(add_money_greater_than())}
      #{Money.DDL.execute_each(add_money_greater_than_or_equal())}
      #{Money.DDL.execute_each(add_money_less_than())}
      #{Money.DDL.execute_each(add_money_less_than_or_equal())}
      #{Money.DDL.execute_each(add_money_sub())}
      #{Money.DDL.execute_each(add_money_neg())}
      """
    end

    def install(1) do
      """
      #{Money.DDL.execute_each(add_money_greater_than())}
      #{Money.DDL.execute_each(add_money_greater_than_or_equal())}
      #{Money.DDL.execute_each(add_money_less_than())}
      #{Money.DDL.execute_each(add_money_less_than_or_equal())}
      #{Money.DDL.execute_each(add_money_sub())}
      #{Money.DDL.execute_each(add_money_mult())}
      #{Money.DDL.execute_each(add_money_neg())}
      """
    end

    def install(0) do
      """
      #{Money.DDL.execute_each(add_money_greater_than())}
      #{Money.DDL.execute_each(add_money_greater_than_or_equal())}
      #{Money.DDL.execute_each(add_money_less_than())}
      #{Money.DDL.execute_each(add_money_less_than_or_equal())}
      #{Money.DDL.execute_each(Money.DDL.create_money_with_currency())}
      #{Money.DDL.execute_each(add_money_sub())}
      #{Money.DDL.execute_each(add_money_neg())}
      #{Money.DDL.execute_each(Money.DDL.define_plus_operator())}
      #{Money.DDL.execute_each(Money.DDL.define_minmax_functions())}
      #{Money.DDL.execute_each(Money.DDL.define_sum_function())}
      #{Money.DDL.execute_each(add_money_mult())}
      """
    end

    def uninstall(4) do
      """
      #{Money.DDL.execute_each(remove_money_greater_than())}
      #{Money.DDL.execute_each(remove_money_greater_than_or_equal())}
      #{Money.DDL.execute_each(remove_money_less_than())}
      #{Money.DDL.execute_each(remove_money_less_than_or_equal())}
      #{uninstall(3)}
      """
    end

    def uninstall(3) do
      """
      #{Money.DDL.execute_each(remove_money_sub())}
      #{Money.DDL.execute_each(remove_money_neg())}
      #{uninstall(2)}
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

    defp add_money_greater_than do
      """
      CREATE OR REPLACE FUNCTION money_gt(money_1 money_with_currency, money_2 money_with_currency)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          IF currency_code(money_1) = currency_code(money_2) THEN
            currency := currency_code(money_1);
            result := amount(money_1) > amount(money_2);
            return result;
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes for > operator. Expected both currency codes to be %', currency_code(money_1)
              USING HINT = 'Please ensure both columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;


      CREATE OR REPLACE FUNCTION money_gt(money_1 money_with_currency, amount numeric)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          currency := currency_code(money_1);
          result := amount(money_1) > amount;
          return result;
        END;
      $$;


      CREATE OPERATOR > (
          leftarg = money_with_currency,
          rightarg = money_with_currency,
          procedure = money_gt
      );


      CREATE OPERATOR > (
          leftarg = money_with_currency,
          rightarg = numeric,
          procedure = money_gt
      );
      """
    end

    defp add_money_greater_than_or_equal do
      """
      CREATE OR REPLACE FUNCTION money_gte(money_1 money_with_currency, money_2 money_with_currency)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          IF currency_code(money_1) = currency_code(money_2) THEN
            currency := currency_code(money_1);
            result := amount(money_1) >= amount(money_2);
            return result;
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes for >= operator. Expected both currency codes to be %', currency_code(money_1)
              USING HINT = 'Please ensure both columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;


      CREATE OR REPLACE FUNCTION money_gte(money_1 money_with_currency, amount numeric)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          currency := currency_code(money_1);
          result := amount(money_1) >= amount;
          return result;
        END;
      $$;


      CREATE OPERATOR >= (
          leftarg = money_with_currency,
          rightarg = money_with_currency,
          procedure = money_gt
      );


      CREATE OPERATOR >= (
          leftarg = money_with_currency,
          rightarg = numeric,
          procedure = money_gt
      );
      """
    end

    defp add_money_less_than do
      """
      CREATE OR REPLACE FUNCTION money_lt(money_1 money_with_currency, money_2 money_with_currency)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          IF currency_code(money_1) = currency_code(money_2) THEN
            currency := currency_code(money_1);
            result := amount(money_1) < amount(money_2);
            return result;
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes for < operator. Expected both currency codes to be %', currency_code(money_1)
              USING HINT = 'Please ensure both columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;


      CREATE OR REPLACE FUNCTION money_lt(money_1 money_with_currency, amount numeric)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          currency := currency_code(money_1);
          result := amount(money_1) < amount;
          return result;
        END;
      $$;


      CREATE OPERATOR < (
          leftarg = money_with_currency,
          rightarg = money_with_currency,
          procedure = money_lt
      );


      CREATE OPERATOR < (
          leftarg = money_with_currency,
          rightarg = numeric,
          procedure = money_lt
      );
      """
    end

    defp add_money_less_than_or_equal do
      """
      CREATE OR REPLACE FUNCTION money_lte(money_1 money_with_currency, money_2 money_with_currency)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          IF currency_code(money_1) = currency_code(money_2) THEN
            currency := currency_code(money_1);
            result := amount(money_1) <= amount(money_2);
            return result;
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes for <= operator. Expected both currency codes to be %', currency_code(money_1)
              USING HINT = 'Please ensure both columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;


      CREATE OR REPLACE FUNCTION money_lte(money_1 money_with_currency, amount numeric)
      RETURNS BOOLEAN
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          result boolean;
        BEGIN
          currency := currency_code(money_1);
          result := amount(money_1) <= amount;
          return result;
        END;
      $$;


      CREATE OPERATOR <= (
          leftarg = money_with_currency,
          rightarg = money_with_currency,
          procedure = money_lte
      );


      CREATE OPERATOR <= (
          leftarg = money_with_currency,
          rightarg = numeric,
          procedure = money_lte
      );
      """
    end

    defp remove_money_greater_than do
      """
      DROP OPERATOR >(money_with_currency, money_with_currency);


      DROP OPERATOR >(money_with_currency, numeric);


      DROP FUNCTION IF EXISTS money_gt(money_1 money_with_currency, money_2 money_with_currency);


      DROP FUNCTION IF EXISTS money_gt(money_1 money_with_currency, amount numeric);
      """
    end

    defp remove_money_greater_than_or_equal do
      """
      DROP OPERATOR >=(money_with_currency, money_with_currency);


      DROP OPERATOR >=(money_with_currency, numeric);


      DROP FUNCTION IF EXISTS money_gte(money_1 money_with_currency, money_2 money_with_currency);


      DROP FUNCTION IF EXISTS money_gte(money_1 money_with_currency, amount numeric);
      """
    end

    defp remove_money_less_than do
      """
      DROP OPERATOR <(money_with_currency, money_with_currency);


      DROP OPERATOR <(money_with_currency, numeric);


      DROP FUNCTION IF EXISTS money_lt(money_1 money_with_currency, money_2 money_with_currency);


      DROP FUNCTION IF EXISTS money_lt(money_1 money_with_currency, amount numeric);
      """
    end

    defp remove_money_less_than_or_equal do
      """
      DROP OPERATOR <=(money_with_currency, money_with_currency);


      DROP OPERATOR <=(money_with_currency, numeric);


      DROP FUNCTION IF EXISTS money_lte(money_1 money_with_currency, money_2 money_with_currency);


      DROP FUNCTION IF EXISTS money_lte(money_1 money_with_currency, amount numeric);
      """
    end

    defp add_money_neg do
      """
      CREATE OR REPLACE FUNCTION money_neg(money_1 money_with_currency)
      RETURNS money_with_currency
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          addition numeric;
        BEGIN
          currency := currency_code(money_1);
          addition := amount(money_1) * -1;
          return row(currency, addition);
        END;
      $$;


      CREATE OPERATOR - (
          rightarg = money_with_currency,
          procedure = money_neg
      );
      """
    end

    defp remove_money_neg do
      """
      DROP OPERATOR -(none, money_with_currency);


      DROP FUNCTION IF EXISTS money_neg(money_1 money_with_currency);
      """
    end

    defp add_money_sub do
      """
      CREATE OR REPLACE FUNCTION money_sub(money_1 money_with_currency, money_2 money_with_currency)
      RETURNS money_with_currency
      IMMUTABLE
      STRICT
      LANGUAGE plpgsql
      AS $$
        DECLARE
          currency varchar;
          subtraction numeric;
        BEGIN
          IF currency_code(money_1) = currency_code(money_2) THEN
            currency := currency_code(money_1);
            subtraction := amount(money_1) - amount(money_2);
            return row(currency, subtraction);
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes for - operator. Expected both currency codes to be %', currency_code(money_1)
              USING HINT = 'Please ensure both columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;


      CREATE OPERATOR - (
          leftarg = money_with_currency,
          rightarg = money_with_currency,
          procedure = money_sub,
          commutator = -
      );
      """
    end

    defp remove_money_sub do
      """
      DROP OPERATOR - (money_with_currency, money_with_currency);


      DROP FUNCTION IF EXISTS money_sub(money_1 money_with_currency, money_2 money_with_currency);
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
