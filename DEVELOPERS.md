# Developer guide

## Dev shell

Use the project dev shell for local developer tooling:

```shell
nix develop
```

The default dev shell includes:

- `act`
- `actionlint`
- `docker`
- `gh`
- `lefthook`

Prefer adding developer-facing tools from `nixpkgs` to the project's dev shell
before introducing ad hoc installers or one-off bootstrap scripts.

## Local hooks

If you want Git-managed local hooks, install Lefthook after entering the dev
shell:

```shell
lefthook install
```

The configured `pre-push` hook currently:

- runs `nix flake check --no-build` when `flake.nix`, `flake.lock`, or
  `tests/**/*.nix` changed
- runs `actionlint` when workflow files under `.github/workflows/` changed

These hooks are local convenience only. GitHub Actions CI is the real
enforcement mechanism for this repo.

## Publishing changes

### Git push

For ordinary `git push` flows, installed Lefthook hooks can run local checks
before the push proceeds.

### jj spr

If you publish changes with `jj spr`, do not assume Git `pre-push` hooks will
run. In that flow, run the relevant checks yourself before publishing, for
example:

```shell
nix flake check --no-build
jj spr diff -r @
```

## CI automation

The repo includes GitHub Actions workflows for:

- daily updates to `flakelight` and `nix-wrapper-modules`
- weekly updates to the root `nixpkgs` input

Both workflows validate with:

```shell
nix flake check --no-build
```
