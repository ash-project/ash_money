# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](Https://conventionalcommits.org) for commit guidelines.

<!-- changelog -->

## [v0.2.3](https://github.com/ash-project/ash_money/compare/v0.2.2...v0.2.3) (2025-06-25)




### Bug Fixes:

* add ex_cldr dependency by Zach Daniel

## [v0.2.2](https://github.com/ash-project/ash_money/compare/v0.2.1...v0.2.2) (2025-06-16)




### Bug Fixes:

* don't set search_path in migrations by Zach Daniel

## [v0.2.1](https://github.com/ash-project/ash_money/compare/v0.2.0...v0.2.1) (2025-05-30)




### Improvements:

* fix igniter warnings

## [v0.2.0](https://github.com/ash-project/ash_money/compare/v0.1.19...v0.2.0) (2025-04-09)




### Features:

* add ex_money_opts contstraint to AshMoney.Types.Money (#117)

### Bug Fixes:

* AshMoney.Types.Money cast_input and cast_stored (#118)

## [v0.1.19](https://github.com/ash-project/ash_money/compare/v0.1.18...v0.1.19) (2025-03-04)




### Bug Fixes:

* install into all repos, and if any repo is found

## [v0.1.18](https://github.com/ash-project/ash_money/compare/v0.1.17...v0.1.18) (2025-03-03)




### Bug Fixes:

* don't ask for confirmation if --yes is passed to installer

## [v0.1.17](https://github.com/ash-project/ash_money/compare/v0.1.16...v0.1.17) (2025-02-28)




### Bug Fixes:

* generate migrations to fix >= operator

* Fix `money_gte` function to use the correct operator (#110)

## [v0.1.16](https://github.com/ash-project/ash_money/compare/v0.1.15...v0.1.16) (2025-02-24)




### Bug Fixes:

* include decimal types in multiplication evaluator

* case clause error in greater than or equal operator evaluator

## [v0.1.15](https://github.com/ash-project/ash_money/compare/v0.1.14...v0.1.15) (2024-12-20)




### Bug Fixes:

* multiplication returns a money

### Improvements:

* make igniter optional

* prefer decimals in type signatures

## [v0.1.14](https://github.com/ash-project/ash_money/compare/v0.1.13...v0.1.14) (2024-11-28)




### Bug Fixes:

* properly spec extended operators

## [v0.1.13](https://github.com/ash-project/ash_money/compare/v0.1.12...v0.1.13) (2024-09-10)




### Improvements:

* use latest igniter functions & update dependency

* add short code automatically

## [v0.1.12](https://github.com/ash-project/ash_money/compare/v0.1.11...v0.1.12) (2024-08-08)




### Improvements:

* use `string` not `number` for amount type in json schema

## [v0.1.11](https://github.com/ash-project/ash_money/compare/v0.1.10...v0.1.11) (2024-08-08)




### Improvements:

* set up AshJsonApi type automatically

## [v0.1.10](https://github.com/ash-project/ash_money/compare/v0.1.9...v0.1.10) (2024-07-15)

### Improvements:

- [`mix ash_money.install`] add Igniter installer task (#61)

## [v0.1.9](https://github.com/ash-project/ash_money/compare/v0.1.8...v0.1.9) (2024-06-24)

### Bug Fixes:

- move create_money_with_currency to first (#60)

## [v0.1.8](https://github.com/ash-project/ash_money/compare/v0.1.7...v0.1.8) (2024-06-18)

### Improvements:

- add comparison operators to the extension

- add more operator overloads

## [v0.1.7](https://github.com/ash-project/ash_money/compare/v0.1.6...v0.1.7) (2024-05-12)

### Improvements:

- add money sub & negation operators

## [v0.1.6](https://github.com/ash-project/ash_money/compare/v0.1.6-rc.2...v0.1.6) (2024-05-10)

## [v0.1.6-rc.2](https://github.com/ash-project/ash_money/compare/v0.1.6-rc.1...v0.1.6-rc.2) (2024-05-05)

### Bug Fixes:

- update ash_postgres dependency and fix version numbers in extension

## [v0.1.6-rc.1](https://github.com/ash-project/ash_money/compare/v0.1.6-rc.0...v0.1.6-rc.1) (2024-04-29)

### Improvements:

- add `Comp` implementation for money

- support casting atomic in money type

## [v0.1.6-rc.0](https://github.com/ash-project/ash_money/compare/v0.1.5...v0.1.6-rc.0) (2024-04-01)

## [v0.1.5](https://github.com/ash-project/ash_money/compare/v0.1.4...v0.1.5) (2024-04-01)

### Bug Fixes:

- remove duplicate money mult postgres install (#3)

## [v0.1.4](https://github.com/ash-project/ash_money/compare/v0.1.3...v0.1.4) (2024-01-04)

### Improvements:

- support new operator overrides and multiplication

## [v0.1.3](https://github.com/ash-project/ash_money/compare/v0.1.2...v0.1.3) (2023-12-06)

### Bug Fixes:

- typespecs and upgrade `ash_graphql`

## [v0.1.2](https://github.com/ash-project/ash_money/compare/v0.1.1...v0.1.2) (2023-12-04)

### Bug Fixes:

- add composite type storage_alias

### Improvements:

- add more optional deps for proper compile order

- docs & optional deps

- support new `Ash.Type` composite type callbacks

## [v0.1.1](https://github.com/ash-project/ash_money/compare/v0.1.0...v0.1.1) (2023-11-27)

### Bug Fixes:

- handle missing `ex_money_sql` better

## [v0.1.0](https://github.com/ash-project/ash_money/compare/v0.1.0...v0.1.0) (2023-11-27)

- Initial Release
