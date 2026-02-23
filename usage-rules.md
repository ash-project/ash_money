<!--
SPDX-FileCopyrightText: 2023 ash_money contributors <https://github.com/ash-project/ash_money/graphs/contributors>

SPDX-License-Identifier: MIT
-->

# AshMoney Usage Rules

AshMoney provides `AshMoney.Types.Money` (aliased as `:money` if configured), backed by `ex_money`.

## Type Usage

```elixir
attribute :balance, :money
attribute :balance, AshMoney.Types.Money
```

### Constraints

- `storage_type` — `:money_with_currency` (default, requires `ex_money_sql` for Postgres) or `:map`
- `min` / `max` — decimal bounds on the amount
- `ex_money_opts` — keyword list passed to `Money.new/3`

```elixir
attribute :charge, :money do
  constraints min: Decimal.new("0"), max: Decimal.new("1000")
end
```

## Constructing Values

```elixir
Money.new(:USD, "100.00")
Money.new!("EUR", Decimal.new("50"))
```

In expressions (composite type):

```elixir
composite_type(%{currency: "USD", amount: Decimal.new("0")}, :money)
```

## Expressions and Operator Overloads

Supported in Ash expressions (runtime and Postgres when the extension is installed):

- `+` — add two `Money` values
- `-` — subtract two `Money` values; unary negation
- `*` — multiply `Money` by a `decimal`
- `<`, `<=`, `>`, `>=` — compare two `Money` values, or `Money` against a `decimal`

Currency mismatches raise errors. All arithmetic requires matching currencies.

## AshPostgres

With `AshMoney.AshPostgresExtension` installed, money operations push down to SQL. Access composite fields in expressions via:

```elixir
filter expr(balance[:currency_code] == "USD")
```

Aggregates work naturally:

```elixir
sum :total, :line_items, :amount
```
