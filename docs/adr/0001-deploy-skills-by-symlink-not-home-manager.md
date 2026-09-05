# 0001. Deploy skills by symlink, not by Home Manager

- Status: Accepted
- Date: 2026-09-05

## Context

Personal, user-level Claude Code skills lived only in `~/.claude/skills` as
eight hand-written directories. They were in no repository and under no
configuration management: the single copy on one machine was the whole of it.
One of them, `grill-with-docs`, referenced a `/domain-modeling` skill that
does not exist anywhere on the machine, and nothing had surfaced that.

Two facts about the surrounding setup constrain how this repository can place
its files.

**Home Manager here has exactly one owner.** `hypatia-tile/dotfiles-mac`
wires Home Manager as a nix-darwin module and sets
`users.<user> = import ./modules/home`. A standalone Home Manager
configuration in this repository would give the same user a second generation,
and the two would clobber each other's `home.file` manifests. This is not a
preference; the two arrangements do not compose.

**The house pattern for "config in its own repository" is store-pinned and
read-only.** `hypatia-tile/nvim-config` is a separate repository consumed as a
`flake = false` input and placed with
`xdg.configFile."nvim".source = inputs.nvim-config`. Its own comment in
`modules/home/files.nix` names the cost: editing it means pushing to the
repository and bumping the pin. The placed files live in `/nix/store` and are
read-only.

Skills differ from every other configuration in one respect that decides this
question. A skill is prompt text that the agent reads, and it is the agent
itself that rewrites it, mid-session, in response to "fix this skill". Under
the store-pinned pattern the most common operation on a skill becomes commit,
push, `nix flake update`, `darwin-rebuild switch` — four steps, the last of
which rebuilds the system closure, before the edit can be tried at all.

## Decision

This repository is the source of truth for `~/.claude/skills`. It holds them
at `.claude/skills/`, mirroring the path they occupy at home.

**`nix run .#install` creates a single symlink** from `~/.claude/skills` to
this checkout's `.claude/skills`. Home Manager is not involved, and neither
`dotfiles-mac` nor any other repository needs to change.

The link must resolve to the working tree, so the installer discovers the
repository root with `git rev-parse --show-toplevel` rather than using the
flake's own `/nix/store` path. Running it from outside a checkout is an error
that says to clone first.

**One symlink for the whole directory**, not one per skill. There is then no
state in which the repository and `~/.claude/skills` disagree, and `git
status` in this repository is the complete truth about what is installed.

**The installer never destroys content.** A non-empty real directory at the
target is refused with instructions, because on a first install that
directory holds the only copy of what is being migrated. An empty directory
is removed (Claude Code creates one), a link already pointing here is a
no-op, and a link pointing elsewhere is repointed. `nix run .#uninstall`
removes only a link that points at this checkout.

The generalizable criterion, for other repositories facing the same choice:
**pin content into the store when reproducibility is what is wanted, and
symlink the working tree when the content is edited far more often than the
machine is rebuilt.**

## Consequences

- An edit takes effect in every session on this machine immediately, with no
  rebuild. This is the point of the decision and also its sharpest edge: a
  half-finished experiment in the working tree is already live everywhere,
  including in unrelated projects.
- `~/.claude/skills` is no longer declarative. A new machine needs the clone
  and one manual `nix run .#install`; until then it has no skills. This is
  the cost accepted in exchange for the point above.
- Because the target is a directory symlink, a session in another project
  that writes to `~/.claude/skills/<name>/SKILL.md` is writing into this
  working tree, and this repository's `.claude/settings.json` does not apply
  to that session. Such writes are visible in `git status` and nowhere else.
- The pattern is reusable but not yet proven. Whether `nvim-config` and the
  `config/*` payloads in `dotfiles-mac` should adopt it is tracked as an
  issue, to be decided by those repositories' own ADRs after this one has
  been in use.
