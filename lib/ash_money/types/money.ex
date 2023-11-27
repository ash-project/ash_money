defmodule AshMoney.Types.Money do
  @moduledoc """
  A money type for Ash that uses the `ex_money` library.
  """
  use Ash.Type

  @impl Ash.Type
  def constraints do
    [
      storage_type: [
        type: :atom,
        default: :money_with_currency,
        doc: "The storage type for the money value. Can be `:money_with_currency` or `:map`."
      ]
    ]
  end

  @impl true
  def cast_in_query?(constraints) do
    Keyword.get(constraints, :storage_type, :money_with_currency) == :money_with_currency
  end

  @impl Ash.Type
  def storage_type(constraints) do
    if constraints[:items] do
      Keyword.get(constraints[:items], :storage_type, :money_with_currency)
    else
      Keyword.get(constraints, :storage_type, :money_with_currency)
    end
  end

  @impl Ash.Type
  def cast_input(nil, _constraints), do: {:ok, nil}

  def cast_input({amount, currency}, constraints) do
    case Money.new(amount, currency) do
      {:error, error} -> {:error, error}
      money -> cast_input(money, constraints)
    end
  end

  def cast_input(value, constraints) do
    if constraints[:storage_type] == :map do
      Money.Ecto.Map.Type.cast(value)
    else
      Money.Ecto.Composite.Type.cast(value)
    end
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}
  def cast_stored(%Money{} = value, _), do: {:ok, value}

  def cast_stored({_amount, _currency} = value, _constraints),
    do: Money.Ecto.Composite.Type.load(value)

  def cast_stored(value, _constraints) do
    Money.Ecto.Map.Type.load(value)
  end

  @impl Ash.Type
  def dump_to_embedded(nil, _constraints), do: {:ok, nil}

  def dump_to_embedded(value, _constraints) do
    Money.Ecto.Map.Type.dump(value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _constraints), do: {:ok, nil}

  def dump_to_native(value, constraints) do
    if constraints[:storage_type] == :map do
      Money.Ecto.Map.Type.dump(value)
    else
      Money.Ecto.Composite.Type.dump(value)
    end
  end

  if Code.ensure_loaded?(AshGraphql.Type) do
    @behaviour AshGraphql.Type
    @spec graphql_type(term()) :: atom()
    def graphql_type(_), do: :money

    @spec graphql_input_type(term()) :: atom()
    def graphql_input_type(_), do: :money_input
  end

  if Code.ensure_loaded?(AshPostgres.Type) do
    @behaviour AshPostgres.Type

    @impl AshPostgres.Type
    def value_to_postgres_default(__MODULE__, constraints, %Money{
          amount: amount,
          currency: currency
        }) do
      if Keyword.get(constraints, :storage_type, :money_with_currency) == :map do
        {:ok, ~s[fragment("'{\\"amount\\": #{amount}, \\"currency\\": \\"#{currency}\\"}'")]}
      else
        {:ok, ~s[fragment("('#{currency}', #{amount})")]}
      end
    end
  end
end
