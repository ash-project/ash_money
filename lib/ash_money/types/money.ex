defmodule AshMoney.Types.Money do
  @moduledoc """
  A money type for Ash that uses the `ex_money` library.

  When constructing a composite type, use a tuple in the following structure:

  `composite_type(%{currency: "USD", amount: Decimal.new("0")}}, AshMoney.Types.Money)`

  If you've added a custom type, like `:money`:

  ```elixir
  composite_type(%{currency: "USD", amount: Decimal.new("0")}}, :money)
  ```
  """
  use Ash.Type

  @impl Ash.Type
  def constraints do
    [
      storage_type: [
        type: :atom,
        default: :money_with_currency,
        doc:
          "The storage type for the money value. Can be `:money_with_currency` or `:map`. There is no difference between the two unless `ex_money_sql` is installed."
      ]
    ]
  end

  if Code.ensure_loaded?(Money.Ecto.Composite.Type) do
    @composite_type Money.Ecto.Composite.Type
  else
    @composite_type Money.Ecto.Map.Type
  end

  @impl true
  def operator_overloads do
    %{
      :+ => %{
        [__MODULE__, __MODULE__] => __MODULE__
      },
      :- => %{
        [__MODULE__, __MODULE__] => __MODULE__
      },
      :* => %{
        [__MODULE__, :integer] => __MODULE__,
        [:integer, __MODULE__] => __MODULE__
      }
    }
  end

  @impl true
  def evaluate_operator(%Ash.Query.Operator.Basic.Plus{
        left: %Money{} = left,
        right: %Money{} = right
      }) do
    case Money.add(left, right) do
      {:ok, value} ->
        {:known, value}

      _ ->
        :unknown
    end
  end

  def evaluate_operator(%Ash.Query.Operator.Basic.Minus{
        left: %Money{} = left,
        right: %Money{} = right
      }) do
    case Money.sub(left, right) do
      {:ok, value} ->
        {:known, value}

      _ ->
        :unknown
    end
  end

  def evaluate_operator(%Ash.Query.Operator.Basic.Times{
        left: %Money{} = left,
        right: right
      })
      when is_integer(right) do
    case Money.mult(left, right) do
      {:ok, value} ->
        {:known, value}

      _ ->
        :unknown
    end
  end

  def evaluate_operator(%Ash.Query.Operator.Basic.Times{
        left: left,
        right: %Money{} = right
      })
      when is_integer(left) do
    case Money.mult(right, left) do
      {:ok, value} ->
        {:known, value}

      _ ->
        :unknown
    end
  end

  def evaluate_operator(_other) do
    :unknown
  end

  @impl Ash.Type
  def cast_in_query?(constraints) do
    Keyword.get(constraints, :storage_type, :money_with_currency) == :money_with_currency
  end

  @impl Ash.Type
  def composite?(constraints) do
    Keyword.get(constraints, :storage_type, :money_with_currency) == :money_with_currency
  end

  @impl Ash.Type
  def composite_types(_constraints) do
    [{:currency, :currency_code, :string, []}, {:amount, :decimal, []}]
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
  def cast_atomic(%Money{} = value, constraints) do
    case cast_input(value, constraints) do
      {:ok, value} -> {:atomic, value}
      {:error, other} -> {:error, other}
    end
  end

  def cast_atomic(expr, _constraints) do
    {:atomic, expr}
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
      @composite_type.cast(value)
    end
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}
  def cast_stored(%Money{} = value, _), do: {:ok, value}

  def cast_stored({_amount, _currency} = value, _constraints),
    do: @composite_type.load(value)

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
      @composite_type.dump(value)
    end
  end

  if Code.ensure_loaded?(AshGraphql.Type) do
    @behaviour AshGraphql.Type

    @spec graphql_type(term()) :: atom()
    @impl AshGraphql.Type
    def graphql_type(_), do: :money

    @spec graphql_input_type(term()) :: atom()
    @impl AshGraphql.Type
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
