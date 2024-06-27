defmodule Mix.Tasks.AshMoney.Install do
  @moduledoc "Installs AshMoney. Should be run with `mix igniter.install ash_money`"
  @shortdoc @moduledoc
  require Igniter.Code.Common
  use Igniter.Mix.Task

  def igniter(igniter, _argv) do
    Igniter.compose_task(igniter, "ex_cldr.install", [], fn igniter, _argv ->
      cldr = Igniter.Code.Module.module_name("Cldr")

      igniter
      |> setup_cldr_module(cldr)
      |> configure_cldr_config(cldr)
    end)
    |> configure_config()
    |> maybe_add_to_ash_postgres()
  end

  defp setup_cldr_module(igniter, cldr) do
    path = Igniter.Code.Module.proper_location(cldr)

    if Igniter.exists?(igniter, path) do
      igniter
    else
      default_cldr_contents =
        """
        defmodule #{inspect(cldr)} do
          use Cldr,
            locales: ["en"],
            default_locale: "en"
        end
        """

      Igniter.create_new_elixir_file(igniter, path, default_cldr_contents)
    end
  end

  defp configure_cldr_config(igniter, cldr) do
    Igniter.Project.Config.configure_new(
      igniter,
      "config.exs",
      :ex_cldr,
      [:default_backend],
      cldr
    )
  end

  defp configure_config(igniter) do
    Igniter.Project.Config.configure(
      igniter,
      "config.exs",
      :ash,
      [:known_types],
      [AshMoney.Types.Money],
      updater: fn zipper ->
        Igniter.Code.List.prepend_new_to_list(zipper, AshMoney.Types.Money)
      end
    )
  end

  defp maybe_add_to_ash_postgres(igniter) do
    repo = Igniter.Code.Module.module_name("Repo")
    repo_path = Igniter.Code.Module.proper_location(repo)

    if Igniter.exists?(igniter, repo_path) do
      igniter = Igniter.include_existing_elixir_file(igniter, repo_path)

      zipper =
        igniter.rewrite
        |> Rewrite.source!(repo_path)
        |> Rewrite.Source.get(:quoted)
        |> Sourceror.Zipper.zip()

      case Igniter.Code.Module.move_to_module_using(zipper, AshPostgres.Repo) do
        :error ->
          igniter

        _zipper ->
          Igniter.compose_task(igniter, "ash_money.add_to_ash_postgres")
      end
    else
      igniter
    end
  end
end
