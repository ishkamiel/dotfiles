# CLAUDE.md

- Avoid compound commands with git and cd, prefer `git -C <directory>`.
- When using python, default to project-specific pyenv+direnv configuration.

## Claude Code Configuration (managed by ishfiles)

`~/.claude/settings.json` is managed as a dotfile (`dot_claude/dot_settings.json`
in the repo). It declares `enabledPlugins` and `extraKnownMarketplaces` and is
the single source of truth across machines.

Custom skills live in `dot_claude/skills/<name>/SKILL.md` → `~/.claude/skills/<name>/`.
Claude Code auto-discovers them with no registration step.

**Marketplace plugins** cannot be installed from the shell. After running
`ishfiles apply` on a new machine, run `ishfiles runscripts` (or check apply
output) for a list of missing plugins, then install each one inside Claude Code:

```
/plugin install <name>@<marketplace>
```

The derived plugin state under `~/.claude/plugins/` is intentionally unmanaged.
