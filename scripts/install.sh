# shellcheck shell=bash
#
# Point ~/.claude/skills at this checkout's .claude/skills.
#
# The link must resolve to the working tree, not to /nix/store: skills are
# edited mid-session and have to take effect immediately (ADR 0001). That is
# why the repository root is discovered with git rather than taken from the
# flake's own store path.
#
# This never destroys content. A non-empty real directory at the target is
# refused, because on a first install that directory holds the only copy of
# the skills being migrated.

target="${CLAUDE_SKILLS_TARGET:-$HOME/.claude/skills}"

repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z $repo ]]; then
  echo "error: not inside a git checkout." >&2
  echo "Clone the repository first, then run the installer from inside it:" >&2
  echo "  git clone https://github.com/hypatia-tile/skills" >&2
  echo "  cd skills && nix run .#install" >&2
  exit 1
fi

source_dir="$repo/.claude/skills"
if [[ ! -d $source_dir ]]; then
  echo "error: $repo is not the skills repository." >&2
  echo "       expected a directory at $source_dir" >&2
  exit 1
fi

mkdir -p "$(dirname "$target")"

# -L is tested before -e: -e follows the link, so a symlink to an existing
# directory satisfies both, and a dangling symlink satisfies neither.
if [[ -L $target ]]; then
  current="$(readlink "$target")"
  if [[ $current == "$source_dir" ]]; then
    echo "ok: $target already points at $source_dir"
    exit 0
  fi
  rm "$target"
  ln -s "$source_dir" "$target"
  echo "ok: repointed $target"
  echo "    was: $current"
  echo "    now: $source_dir"
  exit 0
fi

if [[ -e $target ]]; then
  if [[ -d $target && -z "$(ls -A "$target")" ]]; then
    rmdir "$target"
    ln -s "$source_dir" "$target"
    echo "ok: replaced the empty directory at $target"
    exit 0
  fi

  echo "error: $target already exists and is not empty." >&2
  echo "       Refusing to touch it; it may hold the only copy of its contents." >&2
  echo "" >&2
  echo "To migrate it into this repository:" >&2
  echo "  1. move each skill directory into $source_dir" >&2
  echo "  2. commit and push it" >&2
  echo "  3. remove $target" >&2
  echo "  4. run this installer again" >&2
  exit 1
fi

ln -s "$source_dir" "$target"
echo "ok: linked $target -> $source_dir"
