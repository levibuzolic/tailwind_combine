# Changelog

## 0.4.0

  - Added a public `TailwindCombine.merge/1` API using the default config.
  - Expanded Tailwind CSS merge support to align much more closely with the upstream JS package, [`tailwind-merge`](https://www.npmjs.com/package/tailwind-merge), including modern Tailwind v4 semantics.
  - Added support for prefixed configs via `TailwindCombine.Config.new(prefix: ...)`.
  - Improved merge input handling for nested lists with `nil` and `false` values.
  - Greatly expanded parity coverage against the upstream JS test suite.

## 0.3.1

  - Unknown classes fall through as-is.

## 0.3.0

  - More config changes.

## 0.2.0

  - Changes to how default config is defined.

## 0.1.0

Initial release.
