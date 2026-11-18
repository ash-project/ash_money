# SPDX-FileCopyrightText: 2023 ash_money contributors <https://github.com/ash-project/ash_money/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshMoney.AshPostgresExtensionTest do
  use ExUnit.Case, async: true

  alias AshMoney.AshPostgresExtension

  @subtraction ~r/CREATE OPERATOR - \(\s*leftarg = money_with_currency,\s*rightarg = money_with_currency,\s*procedure = money_sub\s*\);/

  test "a fresh install creates subtraction without a commutator" do
    sql = AshPostgresExtension.install(0)

    assert sql =~ @subtraction
    refute sql =~ "commutator = -"
  end

  test "every upgrade recreates subtraction without a commutator" do
    {_name, latest_version, _install, _uninstall} = AshPostgresExtension.extension()

    for version <- 1..(latest_version - 1) do
      sql = AshPostgresExtension.install(version)

      assert sql =~ @subtraction, "install(#{version}) does not create subtraction"
      refute sql =~ "commutator = -", "install(#{version}) declares a commutator for subtraction"
    end
  end
end
