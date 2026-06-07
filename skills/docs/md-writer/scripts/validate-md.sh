#!/usr/bin/env bash
set -euo pipefail

# Validate a markdown file with markdownlint.
# Usage: validate-md.sh <file.md>
# Walks up from the target file to find a project-level config.
# Falls back to the skill's bundled config/markdownlint-default.json.
# Exit codes: 0 = clean (or skipped), 1 = invalid invocation, 2 = markdownlint violations.

file_path="${1:-}"

if [[ -z "${file_path}" ]]; then
  echo "usage: validate-md.sh <file.md>" >&2
  exit 1
fi

if [[ ! -f "${file_path}" ]]; then
  echo "file not found: ${file_path}" >&2
  exit 1
fi

if [[ "${file_path}" != *.md ]]; then
  echo "not a markdown file: ${file_path}" >&2
  exit 1
fi

# Skip anything inside a .claude/ directory (plans, memory, etc.)
if [[ "${file_path}" == */.claude/* ]]; then
  exit 0
fi

# Skip well-known repository meta files (READMEs, agent guides, the standard
# GitHub community-health docs, license, changelog). These follow their own
# hand-maintained conventions, not documentation/knowledge-base style — linting
# them only makes them harder to maintain. The validator targets doc content,
# not repo metadata.
#
# The list is intentionally limited to names that are unambiguously metadata
# wherever they appear. Generic English words (CHANGES, HISTORY, SUPPORT,
# AUTHORS, NOTICE, GOVERNANCE, …) are deliberately excluded: a knowledge base
# may legitimately have a `docs/support.md` or `docs/history.md` page, and those
# should be linted like any other doc rather than silently skipped.
stem="$(basename "${file_path}" .md | tr '[:lower:]' '[:upper:]')"
case "${stem}" in
  README | CLAUDE | AGENTS | CONTRIBUTING | CHANGELOG | CODE_OF_CONDUCT \
    | SECURITY | LICENSE | LICENCE | COPYING)
    echo "skipping well-known meta file (not linted): ${file_path}" >&2
    exit 0
    ;;
  *) ;;
esac

# Canonicalize file_path to an absolute path so config discovery works after cd.
# Split out the steps so no command substitution masks another's exit status.
file_dir="$(dirname "${file_path}")"
file_base="$(basename "${file_path}")"
abs_dir="$(cd "${file_dir}" 2>/dev/null && pwd || true)"
if [[ -z "${abs_dir}" ]]; then
  echo "cannot access directory: ${file_dir}" >&2
  exit 1
fi
file_path="${abs_dir}/${file_base}"

# Skill root (this script lives in <skill>/scripts/); config/ and node_modules/
# are siblings of scripts/.
plugin_dir="${CLAUDE_SKILL_DIR:-$(cd "$(dirname "${0}")/.." && pwd)}"

# Walk up from the markdown file's directory looking for a project config.
config=""
search_dir="$(dirname "${file_path}")"
while [[ "${search_dir}" != "/" ]] && [[ "${search_dir}" != "." ]]; do
  for name in .markdownlint.json .markdownlint.jsonc .markdownlint.yaml .markdownlint.yml; do
    if [[ -f "${search_dir}/${name}" ]]; then
      config="${search_dir}/${name}"
      break 2
    fi
  done
  search_dir="$(dirname "${search_dir}")"
done

# Fall back to the plugin's bundled default.
# markdownlint-cli2 --config requires a file matching supported naming
# conventions (e.g. .markdownlint.json). The bundled file uses a visible
# name to avoid dotfile packaging issues, so we symlink it to a valid name.
# Use a unique temp dir to avoid race conditions with concurrent invocations.
cleanup_dir=""
# shellcheck disable=SC2329  # invoked indirectly via the EXIT trap below
cleanup() { [[ -n "${cleanup_dir}" ]] && rm -rf "${cleanup_dir}"; }
trap cleanup EXIT

if [[ -z "${config}" ]]; then
  cleanup_dir="$(mktemp -d)"
  ln -sf "${plugin_dir}/config/markdownlint-default.json" "${cleanup_dir}/.markdownlint.json"
  config="${cleanup_dir}/.markdownlint.json"
fi

# Prefer the local installed binary (fast); fall back to npx with --yes so a
# missing package installs non-interactively instead of hanging on a prompt;
# exit cleanly if neither is available. The npx version is pinned to match
# package.json so both paths enforce the same rule set (keep them in sync).
markdownlint_version="0.22.1"
local_bin="${plugin_dir}/node_modules/.bin/markdownlint-cli2"
result=""
lint_exit=0
set +e
if [[ -x "${local_bin}" ]]; then
  result="$(cd "${plugin_dir}" && "${local_bin}" --config "${config}" "${file_path}" 2>&1)"
  lint_exit=$?
elif command -v npx >/dev/null 2>&1; then
  result="$(cd "${plugin_dir}" && npx --yes "markdownlint-cli2@${markdownlint_version}" --config "${config}" "${file_path}" 2>&1)"
  lint_exit=$?
else
  exit 0
fi
set -e

if [[ "${lint_exit}" -ne 0 ]]; then
  printf 'markdownlint violations found:\n%s\n' "${result}" >&2
  exit 2
fi

exit 0
