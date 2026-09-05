# CLAUDE.md

The rules for working in this repository are in **`AGENTS.md`**, which is
tool-agnostic and is the source of truth for them. Read it first; everything
below is specific to Claude Code and adds to it rather than restating it.

@AGENTS.md

## Guardrails

`.claude/settings.json` enforces the boundary mechanically, so it survives
context resets:

- **deny** — `git push`; the owner pushes;
- **ask** — `git commit`, which is how "commit only on explicit instruction"
  is implemented;
- **allow** — the read-only verification commands (`nix flake check`,
  `nix build`, `nix eval`, `nix run .#check`, the CI linters, and `git`
  status/diff/log/ls-files/branch).

These settings apply only to sessions working *in* this repository. A session
in another project that writes to `~/.claude/skills/<name>/SKILL.md` is
writing into this working tree without them, because the target is a
directory symlink. Such writes appear in `git status` here and nowhere else,
so `git status` is worth a look at the start of work.

## Skills

The skills in `.claude/skills/` are this repository's payload, and a session
running here reaches them by both routes at once — as user-scoped skills
through the symlink, and as project-scoped skills through the path. They are
surfaced once rather than twice (checked 2026-09-05), so the overlap needs no
handling. Editing one changes the running session's own behaviour.

They are not listed in this file: Claude Code surfaces them from their
frontmatter, and an index maintained in an always-loaded file goes stale.
`README.md` explains what belongs here and what does not.
