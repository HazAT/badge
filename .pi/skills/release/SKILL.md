---
name: release
description: Cut a new release of the badge gem — verify via make smoke, build, tag, push, publish to rubygems, and write a GitHub release matching the project's 2018-era house style. Use when asked to "release", "cut a release", "publish a new version", "tag a release", "new release", "/release", "ship it", or "prepare a release".
---

# Release the badge gem

The project's release ritual. Every step is required unless explicitly
marked optional. Don't freelance — match the conventions below so
`git tag -l` and `gh release list` stay consistent with the last decade
of history.

## Before you start

Verify all of these. If any is false, stop and fix it first.

- On `master` and up-to-date with origin
- Working tree clean
- All release-worthy PRs merged
- `make smoke` passes on plain master

```bash
git status                                        # clean working tree
git pull --ff-only                                # up-to-date with origin
git log --oneline origin/master -5                # sanity check
make smoke                                        # must be 20/20
```

## Step 1: Pick the next version

Semver:
- **patch** (0.13.2 → 0.13.3) — bugfixes, no new options, no breaking changes
- **minor** (0.13.2 → 0.14.0) — new CLI options or new features
- **major** (0.13.2 → 1.0.0) — breaking changes only, **discuss first**

The gem has been `0.x` since 2015 — don't jump to `1.0` without explicit
agreement from the maintainer.

```bash
grep VERSION lib/badge/base.rb                    # current version
git tag --sort=-v:refname | head -5               # most recent tags
```

## Step 2: Bump VERSION if not already done

The project's convention is to bundle the `VERSION` bump into the final
feature PR, not as a separate bump commit. If the VERSION on master
already matches your target, skip to Step 3.

Otherwise bump it now on a short-lived branch and merge via PR (don't
push directly to master):

```bash
git checkout -b release/X.Y.Z
# edit lib/badge/base.rb: VERSION = "X.Y.Z"
git commit -am "chore: bump version to X.Y.Z"
git push -u origin release/X.Y.Z
gh pr create --title "Release X.Y.Z" --body "Version bump for upcoming release." --base master
# merge after review, then back to master and pull
```

## Step 3: Verify — mandatory

`make smoke` is the only test suite this project has. 20 end-to-end
cases. **Must be 20/20** before tagging. Do not skip even if "nothing
looks changed."

```bash
bundle install                                    # if vendor/bundle is stale
make smoke
```

If anything fails, do not release. Fix the regression first.

## Step 4: Build the gem

```bash
make build                                        # → badge-X.Y.Z.gem
```

Verify the file list inside. Expected contents (13 files): `bin/badge`,
`lib/badge.rb`, `lib/badge/*.rb` (5 files), `README.md`, `LICENSE`, and
the 4 PNGs under `assets/`.

```bash
tar -xOf badge-X.Y.Z.gem data.tar.gz | tar -tzf - | sort
```

## Step 5: Create the tag

**Annotated tags. Name = plain version number (no `v` prefix). Message =
`Release X.Y.Z`.** This matches every tag from 0.4.x onward.

```bash
git tag -a X.Y.Z -m "Release X.Y.Z" master
git push origin X.Y.Z
```

Verify the tag landed:

```bash
git cat-file -t X.Y.Z                                         # should print "tag"
gh api repos/HazAT/badge/git/refs/tags/X.Y.Z --jq '.object.sha'
```

## Step 6: Publish to rubygems

### macOS PATH gotcha — read this

`/usr/bin/gem` is system Ruby 2.6, which **cannot load** the Homebrew
Ruby 4.x gems in `~/.gem/gems/`. Symptoms: `incompatible library version`
errors, `hash key "*" is not a Symbol` from rdoc, or syntax errors from
modern JSON. Fix the PATH before running any `gem` command:

```bash
export PATH="/opt/homebrew/opt/ruby@4/bin:$PATH"
unset GEM_HOME GEM_PATH
which gem                                         # expect /opt/homebrew/opt/ruby@4/bin/gem
```

On a dev machine this lives permanently in `~/.zshenv` — if a
contributor hits the error above, that's the fix.

### Sign in (interactive — first time on a machine)

```bash
gem signin                                        # prompts for email, password, OTP
```

### Push

```bash
gem push badge-X.Y.Z.gem
```

**If the agent doesn't have rubygems credentials, hand the push back to
the user with the exact command above.** Don't prompt for credentials or
try to write to `~/.gem/credentials` — let the user run `gem signin` in
their own terminal.

## Step 7: Create the GitHub release

Match the 2018-era house style exactly — every release from 0.4.x to
0.8.7 follows this format, and 0.13.2 revived it. The rules:

- **Empty title** (tag name becomes the display title)
- **Terse bullet list**, one line per change
- **`type: <summary> #<pr>`** format for each bullet (`feat`, `fix`, `docs`, `chore`)
- **No markdown headers, no "What's Changed" boilerplate**
- **@-mention external contributors** at the bottom — they get a notification

```bash
gh release create X.Y.Z --title "" --notes '- feat: <summary> #<pr>
- fix: <summary> #<pr>

Thanks @contributor for the PR.'
```

### If a prior version was tagged but never released

(E.g. 0.13.1 existed as a tag but was never published as a GH release.)
Roll it up with a note at the bottom:

> Rolls up X.Y.N + X.Y.(N+1) (X.Y.N was never tagged or published).

## Step 8: Verify live and clean up

```bash
# Confirm rubygems has the new version
curl -s https://rubygems.org/api/v1/gems/badge.json | \
  ruby -rjson -e 'd = JSON.parse(STDIN.read); puts "#{d["version"]}  (#{d["version_created_at"][0,19]})"'

# Confirm a fresh install works
TMP=$(mktemp -d) && GEM_HOME=$TMP gem install badge --version X.Y.Z --no-document && rm -rf $TMP

# Tidy the local .gem artifact (gitignored, but clean up anyway)
rm -f badge-X.Y.Z.gem
```

## Step 9: Report

Summarize what shipped. Include:
- The rubygems URL (`https://rubygems.org/gems/badge/versions/X.Y.Z`)
- The GitHub release URL
- Any contributors to thank
- Any follow-up work (e.g. "roll next minor when we land #113")

## Gotchas to remember

- **`fastlane-plugin-badge` pins `badge ~> 0.13.0`** (or similar). Patch
  and minor releases under `0.13.x` ship to fastlane users transparently
  — no sister-gem bump needed. A 0.14 bump would require updating the
  plugin's constraint.
- **The tag points at master tip (merge commit), not the VERSION-bump
  commit.** All 0.x tags follow this pattern.
- **No CHANGELOG file** exists in the repo. The GitHub release notes
  serve as release history.
- **GitHub releases were skipped 2018–2025.** Don't take that as
  convention — every release going forward should have one.
- **Don't commit `badge-X.Y.Z.gem` or `vendor/`** — both are in
  `.gitignore` but if you see them in `git status`, something's off.
- **Never publish from a dirty working tree.** `git status` must be
  clean before `gem push`.
