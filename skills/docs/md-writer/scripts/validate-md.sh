#!/usr/bin/env bash

set -eu

# Validate a markdown file with markdownlint.
# Usage: validate-md.sh <file.md>
# Walks up from the target file to find a project-level config.
# Falls back to the skill's bundled config/markdownlint-default.json.
# Exit codes: 0 = clean (or skipped), 1 = invalid invocation, 2 = markdownlint violations.

file_path="${1:-}"

if [ -z "$file_path" ]; then
  echo "usage: validate-md.sh <file.md>" >&2
  exit 1
fi

if [ ! -f "$file_path" ]; then
  echo "file not found: $file_path" >&2
  exit 1
fi

if [[ "$file_path" != *.md ]]; then
  echo "not a markdown file: $file_path" >&2
  exit 1
fi

# Skip anything inside a .claude/ directory (plans, memory, etc.)
if [[ "$file_path" == */.claude/* ]]; then
  exit 0
fi

# Skip well-known repository meta files (READMEs, agent guides, community-health
# and changelog docs). These follow their own hand-maintained conventions, not
# documentation/knowledge-base style — linting them only makes them harder to
# maintain. The validator targets doc content, not repo metadata.
stem="$(basename "$file_path" .md | tr '[:lower:]' '[:upper:]')"
case "$stem" in
  README | CLAUDE | AGENTS | CONTRIBUTING | CHANGELOG | CHANGES | HISTORY \
  | CODE_OF_CONDUCT | CONDUCT | SECURITY | SUPPORT | GOVERNANCE | MAINTAINERS \
  | AUTHORS | CONTRIBUTORS | LICENSE | LICENCE | COPYING | NOTICE \
  | ACKNOWLEDGMENTS | ACKNOWLEDGEMENTS)
    exit 0
    ;;
esac

# Canonicalize file_path to absolute so it resolves correctly after cd
file_path="$(cd "$(dirname "$file_path")" 2>/dev/null && pwd)/$(basename "$file_path")"

# Skill root (this script lives in <skill>/scripts/); config/ and node_modules/
# are siblings of scripts/.
plugin_dir="${CLAUDE_SKILL_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

# Walk up from the markdown file's directory looking for a project config
config=""
search_dir="$(dirname "$file_path")"
while [ "$search_dir" != "/" ] && [ "$search_dir" != "." ]; do
  for name in .markdownlint.json .markdownlint.jsonc .markdownlint.yaml .markdownlint.yml; do
    if [ -f "$search_dir/$name" ]; then
      config="$search_dir/$name"
      break 2
    fi
  done
  search_dir="$(dirname "$search_dir")"
done

# Fall back to the plugin's bundled default.
# markdownlint-cli2 --config requires a file matching supported naming
# conventions (e.g. .markdownlint.json). The bundled file uses a visible
# name to avoid dotfile packaging issues, so we symlink it to a valid name.
# Use a unique temp dir to avoid race conditions with concurrent invocations.
cleanup_dir=""
cleanup() { [ -n "$cleanup_dir" ] && rm -rf "$cleanup_dir"; }
trap cleanup EXIT

if [ -z "$config" ]; then
  cleanup_dir=$(mktemp -d)
  ln -sf "$plugin_dir/config/markdownlint-default.json" "$cleanup_dir/.markdownlint.json"
  config="$cleanup_dir/.markdownlint.json"
fi

# Prefer the local installed binary; fall back to npx; exit if neither available
local_bin="$plugin_dir/node_modules/.bin/markdownlint-cli2"
set +e
if [ -x "$local_bin" ]; then
  result=$(cd "$plugin_dir" && "$local_bin" --config "$config" "$file_path" 2>&1)
  lint_exit=$?
elif command -v npx &> /dev/null; then
  result=$(cd "$plugin_dir" && npx markdownlint-cli2 --config "$config" "$file_path" 2>&1)
  lint_exit=$?
else
  exit 0
fi
set -e

if [ $lint_exit -ne 0 ]; then
  printf 'markdownlint violations found:\n%s\n' "$result" >&2
  exit 2
fi

exit 0
