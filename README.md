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

## Tutorials

- [Getting Started with AshMoney](documentation/tutorials/getting-started-with-ash-money.md)
