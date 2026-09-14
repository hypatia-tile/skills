# skills

> **Archived — moved to
> [`hypatia-tile/dotfiles-mac`](https://github.com/hypatia-tile/dotfiles-mac),
> `config/agents/skills/`.** On 2026-09-14 these skills moved there under
> dotfiles-mac
> [ADR 0028](https://github.com/hypatia-tile/dotfiles-mac/blob/main/docs/adr/0028-user-scope-agent-skills-as-a-payload.md),
> which supersedes [ADR 0001](docs/adr/0001-deploy-skills-by-symlink-not-home-manager.md)
> here. That repository's projector now links them into Claude Code and
> Codex. **Do not run `nix run .#install`**: `~/.claude/skills` is now a real
> directory holding those links, and this checkout is no longer the source.
>
> This repository is kept read-only and is not to be deleted. The copy
> there carries no history, so this is the only place the skills' history
> lives. Everything below describes the arrangement as it was.

Personal, user-level [Claude Code](https://claude.com/claude-code) skills, and
the installer that links them into `~/.claude/skills`.

This repository is the source of truth for those skills. They are not copied
anywhere: `~/.claude/skills` is a symlink to `.claude/skills` here.

## Install

```sh
git clone https://github.com/hypatia-tile/skills
cd skills
nix run .#install
```

The installer refuses to touch a non-empty `~/.claude/skills`, since on a
first install that directory holds the only copy of the skills being
migrated. Move them in here, commit, remove the directory, and run it again.

```sh
nix run .#uninstall   # remove the symlink (only if it points here)
nix run .#check       # validate the skill tree in the working tree
nix flake check       # the same validation, plus everything CI runs
```

## Editing a skill changes every session immediately

Because the link points at the working tree rather than at `/nix/store`, an
edit here is live in every Claude Code session on this machine as soon as it
is saved — before it is committed, and in projects that have nothing to do
with this repository. That immediacy is the reason for the design
([ADR 0001](docs/adr/0001-deploy-skills-by-symlink-not-home-manager.md)) and
its main hazard. Do not leave a half-finished experiment in the tree.

The same link means a session in another project that writes to
`~/.claude/skills/<name>/SKILL.md` is writing into this working tree. Such a
write shows up in `git status` here and nowhere else.

## What belongs here

User scope, in this repository:

- procedures for a **tool, a language, or a way of working** that hold across
  every repository — `clangd-check`, `step-start`, `github-english`.

Project scope, in the repository it serves (`<repo>/.claude/skills/`):

- procedures that depend on **that repository's own file layout, ADRs, CI, or
  issue tracker** — for example the skills in `hypatia-tile/dotfiles-mac`,
  which name its `docs/adr/` numbering and its CI gates.

The test is whether the procedure still makes sense in a repository you have
never seen. If it does, it belongs here.

## Layout

```text
.claude/skills/<name>/SKILL.md   the skills; this directory is what gets linked
scripts/                          install, uninstall, and the validator
flake.nix                         apps and checks over the above
docs/adr/                         decisions
```

Every skill directory must contain a `SKILL.md` whose frontmatter carries a
`name` matching the directory and a non-empty `description`. `nix flake check`
enforces this; a skill that fails these rules is not reported as broken by
Claude Code, it is simply never invoked.

## License

MIT. See [LICENSE](LICENSE).

`grilling` and `handoff` derive from
[mattpocock/skills](https://github.com/mattpocock/skills) and carry its
copyright as well; see [NOTICE.md](NOTICE.md).
