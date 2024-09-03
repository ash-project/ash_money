defmodule Mix.Tasks.AshMoney.Install do
  @moduledoc "Installs AshMoney. Should be run with `mix igniter.install ash_money`"
  @shortdoc @moduledoc
  require Igniter.Code.Common
  use Igniter.Mix.Task

  def igniter(igniter, _argv) do
    Igniter.compose_task(igniter, "ex_cldr.install", [], fn igniter, _argv ->
      cldr_module_name = Igniter.Code.Module.module_name("Cldr")

      igniter
      |> Igniter.Code.Module.find_and_update_or_create_module(
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
    repo_module_name = Igniter.Code.Module.module_name("Repo")

    with {:ok, {igniter, _source, zipper}} <-
           Igniter.Code.Module.find_module(igniter, repo_module_name),
         {:ok, _zipper} <-
           Igniter.Code.Module.move_to_module_using(zipper, AshPostgres.Repo) do
      Igniter.compose_task(igniter, "ash_money.add_to_ash_postgres")
    else
      _ ->
        igniter
    end
  end
end
