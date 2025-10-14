# SPDX-FileCopyrightText: 2023 ash_money contributors <https://github.com/ash-project/ash_money/graphs.contributors>
#
# SPDX-License-Identifier: MIT

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.AshMoney.Install do
    @moduledoc "Installs AshMoney. Should be run with `mix igniter.install ash_money`"
    @shortdoc @moduledoc
    require Igniter.Code.Common
    use Igniter.Mix.Task

    def igniter(igniter) do
      Igniter.compose_task(igniter, "ex_cldr.install", [], fn igniter, _argv ->
        cldr_module_name = Igniter.Project.Module.module_name(igniter, "Cldr")

        igniter =
          if Igniter.Project.Deps.has_dep?(igniter, :ex_cldr) do
            igniter
          else
            Igniter.Project.Deps.add_dep(igniter, {:ex_cldr, "~> 2.0"})
          end

        igniter
        |> Igniter.Project.Module.find_and_update_or_create_module(
          cldr_module_name,
          """
          use Cldr,
            locales: ["en"],
            default_locale: "en"
          """,
          fn zipper -> {:ok, zipper} end
        )
        |> configure_cldr_config(cldr_module_name)
      end)
      |> configure_config()
      |> maybe_add_to_ash_postgres()
    end

    defp configure_cldr_config(igniter, cldr_module_name) do
      Igniter.Project.Config.configure_new(
        igniter,
        "config.exs",
        :ex_cldr,
        [:default_backend],
        cldr_module_name
      )
    end

    defp configure_config(igniter) do
      igniter
      |> Igniter.Project.Config.configure(
        "config.exs",
        :ash,
        [:known_types],
        [AshMoney.Types.Money],
        updater: fn zipper ->
          Igniter.Code.List.append_new_to_list(zipper, AshMoney.Types.Money)
        end
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :ash,
        [:custom_types, :money],
        AshMoney.Types.Money
      )
    end

    defp maybe_add_to_ash_postgres(igniter) do
      case Igniter.Project.Deps.get_dep(igniter, :ash_postgres) do
        {:ok, _} ->
          Igniter.compose_task(igniter, "ash_money.add_to_ash_postgres")

        _ ->
          igniter
      end
    end
  end
else
  defmodule Mix.Tasks.AshMoney.Install do
    @moduledoc "Installs AshMoney. Should be run with `mix igniter.install ash_money`"
    @shortdoc @moduledoc

    @shortdoc "Installs AshMoney. Invoke with `mix igniter.install ash_money`"

    @moduledoc @shortdoc

    def run(_argv) do
      Mix.shell().error("""
      The task 'ash_money.install' requires igniter to be run.

      Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter
      """)

      exit({:shutdown, 1})
    end
  end
end
