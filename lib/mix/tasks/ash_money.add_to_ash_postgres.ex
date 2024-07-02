defmodule Mix.Tasks.AshMoney.AddToAshPostgres do
  @moduledoc "Adds AshMoney.AshPostgresExtension to installed_extensions and installs :ex_money_sql."
  @shortdoc @moduledoc
  require Igniter.Code.Common
  use Igniter.Mix.Task

  @impl Igniter.Mix.Task
  def igniter(igniter, _argv) do
    repo = Igniter.Code.Module.module_name("Repo")

    repo_path = Igniter.Code.Module.proper_location(repo)

    igniter
    |> Igniter.Project.Deps.add_dependency(:ex_money_sql, "~> 1.0")
    |> Igniter.apply_and_fetch_dependencies()
    |> Igniter.update_elixir_file(repo_path, fn zipper ->
      with {:ok, zipper} <- Igniter.Code.Module.move_to_module_using(zipper, AshPostgres.Repo) do
        case Igniter.Code.Module.move_to_def(zipper, :installed_extensions, 0) do
          {:ok, zipper} ->
            case Igniter.Code.Common.move_right(zipper, &Igniter.Code.List.list?/1) do
              {:ok, zipper} ->
                Igniter.Code.List.append_new_to_list(
                  zipper,
                  quote(do: AshMoney.AshPostgresExtension)
                )

              :error ->
                {:error, "installed_extensions/0 doesn't return a list"}
            end

          _ ->
            Igniter.Code.Common.add_code(zipper, """
            def installed_extensions do
              # Add extensions here, and the migration generator will install them.
              [AshMoney.AshPostgresExtension]
            end
            """)
        end
      else
        _ ->
          Igniter.add_issue(
            igniter,
            "Unable to add AshMoney.AshPostgresExtension to installed_extensions/0 in #{inspect(repo)}"
          )
      end
    end)
    |> Igniter.add_task("ash.codegen", ["install_ash_money_extension"])
  end

  @impl Igniter.Mix.Task
  def info(_argv, _source) do
    %Igniter.Mix.Task.Info{
      adds_deps: [:ex_money_sql, "~> 1.0"]
    }
  end
end
