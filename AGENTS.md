# Repository Instructions

- Run project commands through `nix develop -c ...`, including Git commands.
- Use `git` for version-control tasks in this repository.
- Keep changes small and reviewable.
- If a tool session stops tracking state, start a fresh session instead of
  trying to recover by rewriting history.
- `GSTACK_HOME=.gstack` — gstack data lives in the repo, not `~/.gstack/`.

## Developer dependencies

- Prefer adding developer-facing tools from `nixpkgs` to the project's
  `devShell` before introducing ad hoc installers or per-tool bootstrap scripts.
- For broader local workflow and publishing guidance, refer to
  [DEVELOPERS.md](/Users/ren/projects/oss/confix/DEVELOPERS.md).
