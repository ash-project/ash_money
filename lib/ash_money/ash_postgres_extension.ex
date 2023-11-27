if Code.ensure_loaded?(AshPostgres.CustomExtension) do
  defmodule AshMoney.AshPostgresExtension do
    @moduledoc """
    Installs the `money_with_currency` type and operators/functions for Postgres.
    """
    use AshPostgres.CustomExtension, name: :ash_money, latest_version: 1

    def install(1) do
      """
      #{Money.DDL.execute_each(Money.DDL.create_money_with_currency())}
      #{Money.DDL.execute_each(Money.DDL.define_plus_operator())}
      #{Money.DDL.execute_each(Money.DDL.define_minmax_functions())}
      #{Money.DDL.execute_each(Money.DDL.define_sum_function())}
      """
    end

    def uninstall(1) do
      """
      #{Money.DDL.execute_each(Money.DDL.drop_sum_function())}
      #{Money.DDL.execute_each(Money.DDL.drop_minmax_functions())}
      #{Money.DDL.execute_each(Money.DDL.drop_plus_operator())}
      #{Money.DDL.execute_each(Money.DDL.drop_money_with_currency())}
      """
    end
  end
end
