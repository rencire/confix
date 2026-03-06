# AGENTS.md

## Developer dependencies

- Prefer adding developer-facing tools from `nixpkgs` to the project's `devShell` before introducing ad hoc installers or per-tool bootstrap scripts.
- Use the dev shell for local workflow tools and hooks where practical, for example `act`, `docker` CLI, `gh`, and `lefthook`.
- Only fall back to one-off installers or standalone bootstrap logic when a tool cannot be reasonably provided through the flake.
