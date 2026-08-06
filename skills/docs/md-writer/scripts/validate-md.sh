#!/usr/bin/env bash
set -euo pipefail

# Auto-fix and validate a markdown file with markdownlint.
# Usage: validate-md.sh <file.md>
# Exit: 0 = clean or skipped, 1 = bad invocation or linter failure,
# 2 = violations, 3 = linter unavailable.

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

# Second pattern catches a repo-relative `.claude/notes.md`.
if [[ "${file_path}" == */.claude/* || "${file_path}" == .claude/* ]]; then
  exit 0
fi

# Meta files follow their own conventions, not knowledge-base style. Generic names
# (SUPPORT, HISTORY, GOVERNANCE, ...) are excluded on purpose — a docs site may
# legitimately have those pages.
stem="$(basename "${file_path}" .md | tr '[:lower:]' '[:upper:]')"
case "${stem}" in
  README | CLAUDE | AGENTS | CONTRIBUTING | CHANGELOG | CODE_OF_CONDUCT \
    | SECURITY | LICENSE | LICENCE | COPYING)
    echo "skipping well-known meta file (not linted): ${file_path}" >&2
    exit 0
    ;;
  *) ;;
esac

# Absolute path so config discovery survives the cd below. Steps are split so no
# command substitution masks another's exit status.
file_dir="$(dirname "${file_path}")"
file_base="$(basename "${file_path}")"
abs_dir="$(cd "${file_dir}" 2>/dev/null && pwd || true)"
if [[ -z "${abs_dir}" ]]; then
  echo "cannot access directory: ${file_dir}" >&2
  exit 1
fi
file_path="${abs_dir}/${file_base}"

plugin_dir="${CLAUDE_SKILL_DIR:-$(cd "$(dirname "${0}")/.." && pwd)}"

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

# --config needs a supported filename; the bundled default uses a visible name to
# avoid dotfile packaging issues, so symlink it. Unique dir for concurrent runs.
cleanup_dir=""
# shellcheck disable=SC2329  # invoked indirectly via the EXIT trap below
cleanup() { [[ -n "${cleanup_dir}" ]] && rm -rf "${cleanup_dir}"; }
trap cleanup EXIT

if [[ -z "${config}" ]]; then
  cleanup_dir="$(mktemp -d)"
  ln -sf "${plugin_dir}/config/markdownlint-default.json" "${cleanup_dir}/.markdownlint.json"
  config="${cleanup_dir}/.markdownlint.json"
fi

# --fix repairs the mechanical rules in place and reports only what it could not
# fix, so one pass yields both. MD060 table padding needs markdownlint >= 0.41,
# so keep this pin at or above cli2 0.23.2 and in sync with package.json.
markdownlint_version="0.23.2"
local_bin="${plugin_dir}/node_modules/.bin/markdownlint-cli2"
result=""
lint_exit=0

# From stdin so the filename is not part of the digest.
sum_before="$(cksum < "${file_path}")"

set +e
if [[ -x "${local_bin}" ]]; then
  result="$(cd "${plugin_dir}" && "${local_bin}" --fix --config "${config}" "${file_path}" 2>&1)"
  lint_exit=$?
elif command -v npx >/dev/null 2>&1; then
  result="$(cd "${plugin_dir}" && npx --yes "markdownlint-cli2@${markdownlint_version}" --fix --config "${config}" "${file_path}" 2>&1)"
  lint_exit=$?
else
  printf 'markdownlint unavailable: install dependencies in %s or provide npx\n' "${plugin_dir}" >&2
  exit 3
fi
set -e

sum_after="$(cksum < "${file_path}")"

# Fires on exit 0 too — the caller's in-memory copy is stale either way.
if [[ "${sum_before}" != "${sum_after}" ]]; then
  printf 'auto-fixed formatting in place (re-read before further edits): %s\n' "${file_path}" >&2
fi

# npx failures also exit 1, so status alone cannot separate "has violations" from
# "never ran". Every real run prints the version banner.
if [[ "${lint_exit}" -gt 1 ]] ||
  { [[ "${lint_exit}" -eq 1 ]] && ! printf '%s' "${result}" | grep -q 'markdownlint-cli2 v'; }; then
  printf 'markdownlint failed to run (exit %s):\n%s\n' "${lint_exit}" "${result}" >&2
  exit 1
fi

if [[ "${lint_exit}" -ne 0 ]]; then
  printf 'remaining markdownlint violations (not auto-fixable):\n%s\n' "${result}" >&2
  exit 2
fi

exit 0
