# Repository Instructions

- Run project commands through `nix develop -c ...`, including Git commands.
- Use `git` for version-control tasks in this repository.
- Keep changes small and reviewable.
- If a tool session stops tracking state, start a fresh session instead of
  trying to recover by rewriting history.
- `GSTACK_HOME=.gstack` — gstack data lives in the repo, not `~/.gstack/`.

## gstack (REQUIRED — global install)

**Before doing ANY work, verify gstack is installed:**

```bash
test -d ~/.claude/skills/gstack/bin && echo "GSTACK_OK" || echo "GSTACK_MISSING"
```

If GSTACK_MISSING: STOP. Do not proceed. Tell the user:

> gstack is required for all AI-assisted work in this repo. Install it:
>
> ```bash
> git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
> cd ~/.claude/skills/gstack && ./setup --team
> ```
>
> Then restart your AI coding tool.

Do not skip skills, ignore gstack errors, or work around missing gstack.

Using gstack skills: After install, skills like /qa, /ship, /review,
/investigate, and /browse are available. Use /browse for all web browsing. Use
~/.claude/skills/gstack/... for gstack file paths (the global path).
