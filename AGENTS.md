# AGENTS.md

Rules for any coding agent working in this repository. This file is the
source of truth for them; `CLAUDE.md` and any future tool-specific file
(`GEMINI.md`, …) point here and add only what is specific to that tool.
Adding an agent must not fork the rules.

## What this repository is

The source of truth for personal, user-level Claude Code skills.
`~/.claude/skills` is a symlink to `.claude/skills` here, created by
`nix run .#install` (ADR 0001). Repository-specific skills do not live
here; they live in the repository they serve.

## Hard rules

- **An edit here is live immediately, everywhere.** The link points at the
  working tree, not at `/nix/store`, so saving a file changes the behaviour
  of every Claude Code session on this machine at once — before the commit,
  and in projects unrelated to this one. Never leave the tree in a
  half-finished state at the end of a session.
- **Never commit or push automatically.** Prepare the change and a proposed
  Conventional Commit message; commit only when explicitly instructed, and
  never push — the owner pushes and merges.
- **Never delete or overwrite `~/.claude/skills` by hand.** Use
  `nix run .#install` and `nix run .#uninstall`, which refuse rather than
  destroy. The one case they refuse — a non-empty real directory — is
  refused precisely because that directory may hold the only copy of its
  contents. Resolving it is the owner's decision, not a step to take
  unprompted.
- **No secrets in this repository**, ever. It is public, and skills are
  prompt text that invites pasting real commands: no tokens, no internal
  hostnames, no personal paths beyond `$HOME`-relative ones.
- **All repository artifacts are in English** — documents, code, comments,
  commit messages, PR bodies, issues. Conversation with the owner may be in
  Japanese.

## How work is organised

- **A skill is `.claude/skills/<name>/SKILL.md`.** The frontmatter `name`
  must equal the directory name, and `description` must be present and
  non-empty. `nix flake check` enforces both. These failures are silent at
  run time: a skill that breaks them is not reported as broken, it is simply
  never invoked.
- **Decide scope before adding a skill.** It belongs here only if the
  procedure still makes sense in a repository you have never seen. If it
  names a specific repository's file layout, ADR numbering, CI gates, or
  issue tracker, it belongs in that repository's own `.claude/skills/`.
- **A skill copied from elsewhere gets an entry in `NOTICE.md`** — source,
  copyright holder, licence, and the date it was copied — before it is
  committed. This repository is published under MIT, which permits
  redistributing third-party MIT work only with its copyright notice
  attached. Two skills already here were imported without that record and
  the omission survived until the repository was already public.
- **Run `nix flake check` before proposing a commit.** It runs the skill
  validation. Also run the formatters and linters CI runs —
  `nixfmt-rfc-style --check`, `statix`, `deadnix`, `markdownlint` — so a
  trivial format failure does not round-trip through CI.
- Work on short-lived feature branches off `main`, with Conventional Commits.
  One concern per branch. `main` is protected; merge is the owner's.
- **ADRs** live in `docs/adr/NNNN-slug.md` (MADR-lite). Existing ADRs are
  never edited — a changed decision gets a new ADR that supersedes the old
  one.
- **Deferred work lives in GitHub Issues**, not as TODOs in documents. Check
  `gh issue list` before starting a change.

## Working notes

- **A skill is read, not executed.** Its failure mode is not a crash but a
  wrong or absent behaviour some sessions later, which is why the checks
  above are mechanical and why editing one is treated as a live change.
- **Verify empirically; do not conclude from inference.** Before stating that
  a skill is loaded, that a link points where you think, or that a check
  passes, run the command and read the output.
