# Getting Started With AshMoney

## Bring in the ash_money dependency

```elixir
def deps()
  [
    ...
    {:ash_money, "~> 0.2.1"}
  ]
end
```

## Setup

<!-- tabs-open -->

### Using Igniter (recommended)

```bash
mix igniter.install ash_money
```

### Manual

The primary thing that AshMoney provides is `AshMoney.Types.Money`. This is backed by `ex_money`. You can use it out of the box like so:

```elixir
attribute :balance, AshMoney.Types.Money
```

## Add to known types

To support money operations in runtime expressions, which use `Ash`'s operator overloading feature, we have to tell Ash about the `Ash.Type.Money` using the `known_type` configuration.

```
config :ash, :known_types, [AshMoney.Types.Money]
```

## Referencing with `:money`

You can add it to your compile time list of types for easier reference:

```elixir
config :ash, :custom_types, money: AshMoney.Types.Money
```

Then compile ash again, `mix deps.compile ash --force`, and refer to it like so:

```elixir
attribute :balance, :money
```

## Adding AshPostgres Support

First, add the `:ex_money_sql` dependency to your `mix.exs` file.

Then add `AshMoney.AshPostgresExtension` to your list of `installed_extensions` in your repo, and generate migrations.

```elixir
defmodule YourRepo do
  def installed_extensions do
    [..., AshMoney.AshPostgresExtension]
  end
end
```

<!-- tabs-close -->

## AshPostgres Support

Thanks to `ex_money_sql`, there are excellent tools for lowering support for money into your postgres database. This allows for things like aggregates that sum amounts, and referencing money in expressions:

```elixir
sum :sum_of_usd_balances, :accounts, :balance do
  filter expr(balance[:currency_code] == "USD")
end
```

## AshGraphql Support

Add the following to your schema file:

```elixir
  object :money do
    field(:amount, non_null(:decimal))
    field(:currency, non_null(:string))
  end

  input_object :money_input do
    field(:amount, non_null(:decimal))
    field(:currency, non_null(:string))
  end
```
