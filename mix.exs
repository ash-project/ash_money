# SPDX-FileCopyrightText: 2023 ash_money contributors <https://github.com/ash-project/ash_money/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshMoney.MixProject do
  use Mix.Project

  @version "0.2.5"

  @description """
  The extension for working with money types in Ash.
  """

  def project do
    [
      app: :ash_money,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [plt_add_apps: [:mix]],
      docs: docs(),
      description: @description,
      consolidate_protocols: Mix.env() == :prod,
      source_url: "https://github.com/ash-project/ash_money",
      homepage_url: "https://github.com/ash-project/ash_money"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: [
        "Zach Daniel <zach@zachdaniel.dev>"
      ],
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
      CHANGELOG* documentation usage-rules.md),
      links: %{
        "GitHub" => "https://github.com/ash-project/ash_money",
        "Changelog" => "https://github.com/ash-project/ash_money/blob/main/CHANGELOG.md",
        "Discord" => "https://discord.gg/HTHRaaVPUc",
        "Website" => "https://ash-hq.org",
        "Forum" => "https://elixirforum.com/c/elixir-framework-forums/ash-framework-forum",
        "REUSE Compliance" => "https://api.reuse.software/info/github.com/ash-project/ash_money"
      }
    ]
  end

  defp elixirc_paths(:test) do
    elixirc_paths(:dev) ++ ["test/support"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      logo: "logos/small-logo.png",
      extra_section: "GUIDES",
      before_closing_head_tag: fn type ->
        if type == :html do
          """
          <script>
            if (location.hostname === "hexdocs.pm") {
              var script = document.createElement("script");
              script.src = "https://plausible.io/js/script.js";
              script.setAttribute("defer", "defer")
              script.setAttribute("data-domain", "ashhexdocs")
              document.head.appendChild(script);
            }
          </script>
          """
        end
      end,
      extras: [
        {"README.md", title: "Home"},
        "documentation/tutorials/getting-started-with-ash-money.md",
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        Tutorials: ~r'documentation/tutorials',
        "How To": ~r'documentation/how_to',
        Topics: ~r'documentation/topics',
        DSLs: ~r'documentation/dsls',
        "About AshMoney": [
          "CHANGELOG.md"
        ]
      ],
      groups_for_modules: [
        AshMoney: [
          AshMoney,
          AshMoney.Types.Money
        ],
        AshPostgres: [
          AshMoney.AshPostgresExtension
        ],
        Internals: ~r/.*/
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash, ash_version("~> 3.0 and >= 3.0.15")},
      {:ex_money, "~> 5.15"},
      {:igniter, "~> 0.5 and >= 0.5.30", optional: true},
      {:ex_money_sql, "~> 1.0", optional: true},
      {:ash_postgres, "~> 2.0", optional: true},
      {:ash_graphql, "~> 1.0", optional: true},
      {:ash_json_api, "~> 1.4 and >= 1.4.3", optional: true},
      # dev/test dependencies
      {:ex_doc, "~> 0.36", only: [:dev, :test]},
      {:ex_check, "~> 0.12", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:git_ops, "~> 2.5", only: [:dev, :test]},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      sobelow: "sobelow --skip",
      credo: "credo --strict",
      docs: [
        "docs",
        "spark.replace_doc_links"
      ]
    ]
  end

  defp ash_version(default_version) do
    case System.get_env("ASH_VERSION") do
      nil -> default_version
      "local" -> [path: "../ash", override: true]
      "main" -> [git: "https://github.com/ash-project/ash.git"]
      version -> "~> #{version}"
    end
  end
end
