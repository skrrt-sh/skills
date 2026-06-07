#!/usr/bin/env bash
set -euo pipefail

# Links every skill in this repo into ~/.claude/skills, so the local Claude CLI
# can use them without installing via the skills CLI.

REPO="$(cd "$(dirname "${0}")/.." && pwd)"
DEST="${HOME}/.claude/skills"

# Resolve a path to its canonical absolute form. macOS/BSD readlink lacks the
# GNU -f flag, so prefer realpath and fall back to python3.
resolve_path() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "${1}"
  else
    python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "${1}"
  fi
}

# If ~/.claude/skills is a symlink that resolves into this repo, we'd end up
# writing the per-skill symlinks back into the repo's own skills/ tree. Detect
# and bail out instead of polluting the working copy.
if [[ -L "${DEST}" ]]; then
  resolved="$(resolve_path "${DEST}")"
  case "${resolved}" in
    "${REPO}" | "${REPO}"/*)
      echo "error: ${DEST} is a symlink into this repo (${resolved})." >&2
      echo "Remove it (rm \"${DEST}\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
    *) ;;
  esac
fi

mkdir -p "${DEST}"

# Track basenames we've already linked. Skills live in buckets (ship/, docs/),
# so two buckets could in principle hold a same-named skill; linking both would
# silently clobber the first. Use a delimited string rather than a bash-4
# associative array so this stays portable on macOS's stock bash 3.2.
seen="|"

find "${REPO}/skills" -name SKILL.md -not -path '*/node_modules/*' -print0 |
  while IFS= read -r -d '' skill_md; do
    src="$(dirname "${skill_md}")"
    name="$(basename "${src}")"
    target="${DEST}/${name}"

    case "${seen}" in
      *"|${name}|"*)
        echo "warning: skipping duplicate skill name '${name}' (${src})" >&2
        continue
        ;;
      *) ;;
    esac
    seen="${seen}${name}|"

    # Only ever replace our own symlinks. Refuse to delete a real file or
    # directory so we never destroy user-managed content under ~/.claude/skills.
    if [[ -e "${target}" ]] && [[ ! -L "${target}" ]]; then
      echo "error: refusing to overwrite non-symlink target: ${target}" >&2
      exit 1
    fi

    ln -sfn "${src}" "${target}"
    echo "linked ${name} -> ${src}"
  done
