# Agents Guide

Short notes for agents (and humans) working on `badge` — a Ruby gem that
overlays badges/shields on iOS/tvOS/Android app icons, typically invoked
from fastlane. Core logic is a MiniMagick composite plus an optional
`rsvg-convert` pass for crisp shields from shields.io.

## Layout

| Path | What lives there |
|---|---|
| `lib/badge/base.rb` | `VERSION`, asset paths, shields.io base URLs |
| `lib/badge/runner.rb` | Find icons → fetch shield → composite → write |
| `lib/badge/options.rb` | Every CLI option as a `FastlaneCore::ConfigItem` (each with `env_name`) |
| `lib/badge/icon_catalog.rb` | Parses `*.appiconset/Contents.json` — legacy / single-size / layered |
| `lib/badge/commands_generator.rb` | Commander CLI wiring |
| `bin/badge` | Executable entry point |
| `assets/` | Default badge PNGs (shipped in the gem) + README demo fixtures |
| `Makefile` | `make build` (release gem) / `make create-assets` (regen demos) |

## No tests, no CI — verify manually

There is no test suite and no CI. Claims like "fixed" require actually
running the thing and showing output.

```bash
make build                 # → badge-X.Y.Z.gem, proves the gemspec packages
bin/badge --help           # option surface smoke test
make create-assets         # poor-man's integration test: every flag combo
                           # against two real fixtures. ⚠️ mutates assets/,
                           # so run it in a temp copy.
```

System deps: `brew install imagemagick librsvg`. ImageMagick (or
GraphicsMagick) is mandatory; librsvg is optional but recommended.

## Three icon catalog formats — all must keep working

`IconCatalog.detect_format` parses `Contents.json`:

- **Legacy** — multi-size asset catalog (pre-Xcode 14)
- **Single-size** — Xcode 14+, a single 1024×1024 image
- **Layered** — iOS 18+, `appearances` array with separate `all.png` / `dark.png` / `tint.png`

`--glob` is a legacy escape hatch that **bypasses `IconCatalog` entirely**
and globs the filesystem directly. Don't wire them together.

## Release process (for maintainers)

```bash
# 1. Bump VERSION in lib/badge/base.rb, merge to master.
make build
git tag -a X.Y.Z -m "Release X.Y.Z" master
git push origin X.Y.Z
gem push badge-X.Y.Z.gem
# 2. Optional: GitHub release — match 2018-era style: empty title, bullet
#    list of PRs with `#N` refs inline.
gh release create X.Y.Z --title "" --notes '- feat: …
- fix: …'
```

The sister gem `fastlane-plugin-badge` pins `badge ~> 0.X.0`, so patch
releases ship to fastlane users automatically.

## Gotchas

- **Overwrites icons in place.** That's the design, not a bug.
- **Default badge PNGs are full-canvas** with the beta/alpha graphic baked
  into the corner, so `--badge_gravity` looks like a no-op with the
  defaults. (Known issue #113.)
- **`@@retry_attemps` has a typo** (missing `t`) and is load-bearing —
  either leave it alone or rename every occurrence.
- **`required_ruby_version >= 2.0.0`** in the gemspec is intentional.
  Don't introduce Ruby 2.3+ syntax (`&.`, squiggly heredocs, etc.) without
  also bumping the floor.
- **User input flows into shell commands in `runner.rb`.** All external
  calls (`rsvg-convert`) must use argv-form `system(...)` — never
  backticks or string-interpolated `system`.

## Conventions

- **Commits:** Conventional Commits (`fix:`, `feat:`, `docs:`, …) with a
  body that explains *why*, not just *what*.
- **PRs:** One logical change per PR; merge commits preferred over squash
  (matches repo history).
- **GitHub releases:** terse bullet list, empty title, PR `#N` references
  inline — match the `0.8.x` era.
