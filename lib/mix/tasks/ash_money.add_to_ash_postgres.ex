# SPDX-FileCopyrightText: 2020 Zach Daniel
#
# SPDX-License-Identifier: MIT

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.AshMoney.AddToAshPostgres do
    @shortdoc "Adds AshMoney.AshPostgresExtension to installed_extensions and installs :ex_money_sql."
    @moduledoc """
    #{@shortdoc}

    This is called automatically by `mix igniter.install ash_money` if `AshPostgres` is installed at the time.
    This task is useful if you install `ash_postgres` *after* installing `ash_money`.
    """
    require Igniter.Code.Common
    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _source) do
      %Igniter.Mix.Task.Info{
        schema: [
          yes: :boolean
        ]
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      {igniter, repos} =
        Igniter.Project.Module.find_all_matching_modules(igniter, fn _module, zipper ->
          match?({:ok, _}, Igniter.Code.Module.move_to_use(zipper, AshPostgres.Repo))
        end)

      Enum.reduce(repos, igniter, fn repo, igniter ->
        igniter
        |> Igniter.Project.Deps.add_dep({:ex_money_sql, "~> 1.0"})
        |> Igniter.apply_and_fetch_dependencies(yes: igniter.args.options[:yes])
        |> Igniter.Project.Module.find_and_update_module!(repo, fn zipper ->
          case Igniter.Code.Module.move_to_use(zipper, AshPostgres.Repo) do
            # discarding since we just needed to check that `use AshPostgres.Repo` exists
            {:ok, _zipper} ->
              case Igniter.Code.Function.move_to_def(zipper, :installed_extensions, 0) do
                {:ok, zipper} ->
                  case Igniter.Code.Common.move_right(zipper, &Igniter.Code.List.list?/1) do
                    {:ok, zipper} ->
                      case Igniter.Code.List.append_new_to_list(
                             zipper,
                             AshMoney.AshPostgresExtension
                           ) do
                        {:ok, zipper} ->
                          {:ok, zipper}

                        _ ->
                          {:error,
                           "couldn't append `AshMoney.AshPostgresExtension` to #{inspect(repo)}.installed_extensions/0"}
                      end

                    :error ->
                      {:error, "#{inspect(repo)}.installed_extensions/0 doesn't return a list"}
                  end

                _ ->
                  Igniter.Code.Common.add_code(zipper, """
                  def installed_extensions do
                    # Add extensions here, and the migration generator will install them.
                    [AshMoney.AshPostgresExtension]
                  end
                  """)
              end

            _ ->
              {:error, "Couldn't find `use AshPostgres.Repo` in #{inspect(repo)}"}
          end
        end)
        |> Ash.Igniter.codegen("install_ash_money")
      end)
    end
  end
else
  defmodule Mix.Tasks.AshMoney.AddToAshPostgres do
    @shortdoc "Adds AshMoney.AshPostgresExtension to installed_extensions and installs :ex_money_sql."
    @moduledoc """
    #{@shortdoc}

    This is called automatically by `mix igniter.install ash_money` if `AshPostgres` is installed at the time.
    This task is useful if you install `ash_postgres` *after* installing `ash_money`.
    """

    use Mix.Task

    def run(_argv) do
      Mix.shell().error("""
      The task 'ash_money.add_to_ash_postgres' requires igniter to be run.

      Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter
      """)

      exit({:shutdown, 1})
    end
  end
end
