# shellcheck shell=bash
#
# Remove the ~/.claude/skills symlink created by the installer.
#
# Only a link pointing at this checkout is removed. A link somewhere else is
# not ours, and a real directory is never deleted.

target="${CLAUDE_SKILLS_TARGET:-$HOME/.claude/skills}"

if [[ ! -L $target ]]; then
  if [[ -e $target ]]; then
    echo "error: $target is a real file or directory, not a symlink." >&2
    echo "       Refusing to delete it. Remove it by hand if that is what you want." >&2
    exit 1
  fi
  echo "ok: $target does not exist; nothing to do"
  exit 0
fi

repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z $repo ]]; then
  echo "error: not inside a git checkout, so the link cannot be verified as ours." >&2
  exit 1
fi

source_dir="$repo/.claude/skills"
current="$(readlink "$target")"
if [[ $current != "$source_dir" ]]; then
  echo "error: $target points at $current, not at $source_dir." >&2
  echo "       Refusing to remove a link this checkout did not create." >&2
  exit 1
fi

rm "$target"
echo "ok: removed $target"
