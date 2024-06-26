defmodule Mix.Tasks.AshMoney.AddToAshPostgres do
  @moduledoc "Adds AshMoney.AshPostgresExtension to installed_extensions and installs :ex_money_sql."
  @shortdoc @moduledoc
  require Igniter.Code.Common
  use Igniter.Mix.Task

  def igniter(igniter, _argv) do
    repo = Igniter.Code.Module.module_name("Repo")

    repo_path = Igniter.Code.Module.proper_location(repo)

    igniter
    |> Igniter.Project.Deps.add_dependency(:ex_money_sql, "~> 1.0")
    |> Igniter.add_task("deps.get")
    |> Igniter.update_elixir_file(repo_path, fn zipper ->
      with {:ok, zipper} <- Igniter.Code.Module.move_to_module_using(zipper, AshPostgres.Repo),
           {:ok, zipper} <- Igniter.Code.Module.move_to_def(zipper, :installed_extensions, 0) do
        Igniter.Code.List.append_new_to_list(zipper, quote(do: AshMoney.AshPostgresExtension))
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
end
