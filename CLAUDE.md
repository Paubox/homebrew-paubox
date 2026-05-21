# CLAUDE.md

## Overview

`homebrew-paubox` is the official Homebrew tap for Paubox tools. It is a
small, declarative repository: a single Ruby formula plus two GitHub Actions
workflows that keep the formula in sync with upstream npm releases and
validate every change. The formula does not vendor source; it installs
`paubox-cli` from the npm registry tarball. End users install via
`brew install paubox/paubox/paubox-cli`. The CLI source lives in a separate
repo, `Paubox/paubox-cli`.

## Layout

- `Formula/paubox-cli.rb` — the only formula. Pins `url`, `sha256`,
  `version`, depends on `node`, and uses `std_npm_args(ignore_scripts: false)`
  so that keytar's native postinstall runs while still installing from the
  packed tarball.
- `.github/workflows/update-formula.yml` — scheduled (every 6h) +
  `workflow_dispatch` bumper. Polls `registry.npmjs.org/paubox-cli/latest`,
  recomputes the `sha256`, edits the formula in-place with `sed`, runs
  `brew audit --strict --online`, `brew install --build-from-source`, and
  `brew test`, then commits directly to `master`.
- `.github/workflows/validate-formula.yml` — runs the same audit/install/test
  loop on every PR and every push to `master` that touches `Formula/**`.
  Exists specifically because the bumper only validates on version changes,
  so formula-only edits (refactors, install-block changes) would otherwise
  ship un-validated. Runs on `macos-latest` — Linuxbrew would miss the
  npm-symlink and keytar native-binary issues this catches.
- `README.md` — user-facing install instructions and the current version
  table.
- `LICENSE` — Apache-2.0.

There is no `Casks/`, no `Cellar/`, no helper scripts, and no test
directory beyond the inline `test do` block in the formula.

## Commands That Work in This Repo

All commands assume Homebrew is installed locally (macOS or Linuxbrew).

Lint / audit the formula:

```sh
brew audit --strict --online Formula/paubox-cli.rb
```

Install from the local checkout (does a real install into your Cellar):

```sh
brew install --build-from-source Formula/paubox-cli.rb
```

Run the inline `test do` block (checks `paubox --version` and
`paubox --help`):

```sh
brew test Formula/paubox-cli.rb
```

Trigger the auto-bumper manually (requires repo write access):

```sh
gh workflow run update-formula.yml
```

Recompute the tarball sha256 by hand (matches what the workflow does):

```sh
VER=0.1.3
curl -sL "https://registry.npmjs.org/paubox-cli/-/paubox-cli-${VER}.tgz" \
  | sha256sum | cut -d' ' -f1
```

There is no `make`, no `npm`, no `bundle`. Everything goes through `brew`.

## Dependencies and External Services

- Homebrew (`brew` CLI) — required for every workflow and local task.
- Node.js — declared in the formula via `depends_on "node"`. Installed by
  Homebrew at install time.
- npm registry (`registry.npmjs.org`) — source of truth for the tarball and
  its versions. The auto-bumper queries `/paubox-cli/latest`.
- `Paubox/paubox-cli` — upstream source repo. Changes there are what drive
  version bumps here; this repo never edits CLI source.
- keytar's postinstall — fetches a platform-specific native binary. This is
  why the formula passes `ignore_scripts: false` and why CI must run on
  macOS.

No secrets, no env vars, no `.env` files. The workflows rely only on the
default `GITHUB_TOKEN` (contents: write for the bumper, contents: read for
validate).

## Conventions

- Install from the packed npm tarball, never from a source directory.
  `std_npm_args` (added in the `fix: use std_npm_args` commit) is the
  current correct pattern; do not switch back to `Language::Node.std_npm_args`
  (removed upstream) or to `npm install -g .` against the unpacked source
  (npm 5.0+ symlinks the Homebrew build tempdir, which is how a broken
  install reached production previously — see commit `755379a` and the
  comment block in `validate-formula.yml`).
- `bin.install_symlink Dir["#{libexec}/bin/*"]` is the canonical way to
  expose the CLI entry points; don't hand-roll symlinks.
- Version bumps land as commits authored by `github-actions[bot]` with
  the message `chore: update paubox-cli to vX.Y.Z`. Human edits should use
  a different prefix (`fix:`, `ci:`, `docs:`) so the history stays scannable.
- Every PR that touches `Formula/**` must pass `validate-formula` on a
  macOS runner before merging. Don't disable or path-exclude this workflow.
- The formula's `test do` block is non-negotiable: at minimum assert
  `--version` and `--help` so a broken JS bundle is caught by `brew test`.
- Default branch is `master` (not `main`).
- Only one formula lives in this tap today; if a second is added, the
  validate workflow already loops over `Formula/*.rb` and will pick it up
  automatically — no workflow edit needed.
