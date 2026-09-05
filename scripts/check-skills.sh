# shellcheck shell=bash
#
# Validate a skill tree. Takes the directory holding the skill directories.
#
# The failures caught here are the silent kind: a skill with no description is
# never surfaced to the model, and a name that disagrees with its directory is
# invoked under one spelling and stored under another. Neither produces an
# error at run time — the skill is simply never used.

root="${1:?usage: check-skills <skills-dir>}"

if [[ ! -d $root ]]; then
  echo "error: $root is not a directory" >&2
  exit 1
fi

fail=0
found=0
declare -A seen=()

shopt -s nullglob
for dir in "$root"/*/; do
  found=$((found + 1))
  slug="$(basename "$dir")"
  file="$dir/SKILL.md"

  if [[ ! -f $file ]]; then
    echo "error: $slug: SKILL.md is missing" >&2
    fail=1
    continue
  fi

  if [[ "$(head -n 1 "$file")" != "---" ]]; then
    echo "error: $slug/SKILL.md: does not open with YAML frontmatter" >&2
    fail=1
    continue
  fi

  frontmatter="$(awk 'NR == 1 { next } /^---[[:space:]]*$/ { exit } { print }' "$file")"
  name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
  description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -n 1)"

  if [[ -z $name ]]; then
    echo "error: $slug/SKILL.md: frontmatter has no 'name'" >&2
    fail=1
  elif [[ $name != "$slug" ]]; then
    echo "error: $slug/SKILL.md: name '$name' does not match its directory" >&2
    fail=1
  elif [[ -n ${seen[$name]:-} ]]; then
    echo "error: duplicate skill name '$name'" >&2
    fail=1
  else
    seen[$name]=1
  fi

  if [[ -z $description ]]; then
    echo "error: $slug/SKILL.md: frontmatter has no 'description'" >&2
    fail=1
  fi
done

if [[ $found -eq 0 ]]; then
  echo "error: no skills found under $root" >&2
  fail=1
fi

if [[ $fail -ne 0 ]]; then
  exit 1
fi

echo "ok: $found skills validated"
