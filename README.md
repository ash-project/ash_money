<!--
SPDX-FileCopyrightText: 2020 Zach Daniel

SPDX-License-Identifier: MIT
-->

![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-black-text.png?raw=true#gh-light-mode-only)
![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-white-text.png?raw=true#gh-dark-mode-only)

![Elixir CI](https://github.com/ash-project/ash_money/workflows/CI/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex version badge](https://img.shields.io/hexpm/v/ash_money.svg)](https://hex.pm/packages/ash_money)
[![Hexdocs badge](https://img.shields.io/badge/docs-hexdocs-purple)](https://hexdocs.pm/ash_money)
[![REUSE status](https://api.reuse.software/badge/github.com/ash-project/ash_money)](https://api.reuse.software/info/github.com/ash-project/ash_money)

# AshMoney

Welcome! This is the extension for working with money types in [Ash](https://hexdocs.pm/ash). This is a thin wrapper around the very excellent [ex_money](https://hexdocs.pm/ex_money). It provides:

- An `Ash.Type` for representing `Money`
- An `AshPostgres.Extension` for supporting common money operations directly in the database
- An implementation of `Comp` for `%Money{}`, allowing Ash to compare them.

#### ex_money 6.0 and Localize {: .info}

From this version, `ash_money` requires `ex_money ~> 6.0`. `ex_money 6.0` replaces the `ex_cldr` family of dependencies with the unified [localize](https://hex.pm/packages/localize) package and removes the compile-time CLDR backend system. Any `MyApp.Cldr` backend module, or configuration using `:default_cldr_backend`, should be removed. Locales are now configured through `config :localize` and accessed through the `Localize` module (for example `Localize.put_locale/1`). See the [ex_money 6.0 migration guide](https://hexdocs.pm/ex_money/readme.html#migration-from-5-x-to-6-0) for full details.

## Tutorials

- [Getting Started with AshMoney](documentation/tutorials/getting-started-with-ash-money.md)
