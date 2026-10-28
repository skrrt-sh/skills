#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: configure-ship.sh --strategy <github-flow|trunk-based|gitflow>\n' >&2
}

strategy=''

while [[ "$#" -gt 0 ]]; do
  case "${1}" in
    --strategy)
      strategy="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

case "${strategy}" in
  github-flow | trunk-based | gitflow) ;;
  *)
    usage
    exit 1
    ;;
esac

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  printf 'STATUS=not-a-git-repository\n' >&2
  exit 1
fi

skill_dir="$(cd "$(dirname "${0}")/.." && pwd)"
pointer_asset="${skill_dir}/assets/instruction-pointer.md"
strategy_asset="${skill_dir}/assets/${strategy}.md"

for required_file in "${pointer_asset}" "${strategy_asset}"; do
  if [[ ! -f "${required_file}" ]]; then
    printf 'missing skill asset: %s\n' "${required_file}" >&2
    exit 1
  fi
done

cd "${repo_root}"
mkdir -p .agents

instruction_file='AGENTS.md'
# Claude Code reads AGENTS.md only while none of these exists, so their content moves into it.
migrate_candidates=(CLAUDE.md .claude/CLAUDE.md)

instruction_tmp="$(mktemp "${instruction_file}.tmp.XXXXXX")"
merged_tmp="$(mktemp "${instruction_file}.merged.XXXXXX")"
stripped_tmp="$(mktemp "${instruction_file}.stripped.XXXXXX")"
policy_tmp="$(mktemp '.agents/ship.md.tmp.XXXXXX')"
policy_block_tmp="$(mktemp '.agents/ship.md.block.XXXXXX')"
cleanup() {
  rm -f "${instruction_tmp}" "${merged_tmp}" "${stripped_tmp}" "${policy_tmp}" "${policy_block_tmp}"
}
trap cleanup EXIT

start_marker='<!-- skrrt:ship -->'
end_marker='<!-- /skrrt:ship -->'
legacy_start='<!-- skrrt:branching -->'
legacy_end='<!-- /skrrt:branching -->'

check_markers() {
  local file="${1}" start="${2}" finish="${3}" status="${4}" start_count end_count
  start_count="$(grep -cF "${start}" "${file}" || true)"
  end_count="$(grep -cF "${finish}" "${file}" || true)"
  if [[ "${start_count}" -gt 1 || "${end_count}" -gt 1 || "${start_count}" -ne "${end_count}" ]]; then
    printf 'STATUS=%s FILE=%s\n' "${status}" "${file}" >&2
    exit 1
  fi
}

strip_block() {
  awk -v start="${2}" -v finish="${3}" '
    $0 == start { removing = 1; next }
    removing && $0 == finish { removing = 0; next }
    !removing { print }
  ' "${1}"
}

append_section() {
  if [[ -s "${1}" && -s "${2}" ]]; then
    printf '\n' >> "${1}"
  fi
  awk '1' "${2}" >> "${1}"
}

migrated_files=()

if [[ -f "${instruction_file}" ]]; then
  check_markers "${instruction_file}" "${start_marker}" "${end_marker}" invalid-markers
  check_markers "${instruction_file}" "${legacy_start}" "${legacy_end}" invalid-legacy-markers
  strip_block "${instruction_file}" "${legacy_start}" "${legacy_end}" > "${merged_tmp}"
fi

for candidate in "${migrate_candidates[@]}"; do
  [[ -f "${candidate}" || -L "${candidate}" ]] || continue
  migrated_files+=("${candidate}")
  # A symlink between the two files, or a dangling one, carries no content of its own.
  if [[ ! -f "${candidate}" || "${candidate}" -ef "${instruction_file}" ]]; then
    continue
  fi
  check_markers "${candidate}" "${start_marker}" "${end_marker}" invalid-markers
  check_markers "${candidate}" "${legacy_start}" "${legacy_end}" invalid-legacy-markers
  strip_block "${candidate}" "${legacy_start}" "${legacy_end}" |
    strip_block - "${start_marker}" "${end_marker}" > "${stripped_tmp}"
  append_section "${merged_tmp}" "${stripped_tmp}"
done

if grep -qxF "${start_marker}" "${merged_tmp}"; then
  awk -v start="${start_marker}" -v finish="${end_marker}" '
    FNR == NR { block = block $0 ORS; next }
    $0 == start { printf "%s", block; replacing = 1; next }
    replacing && $0 == finish { replacing = 0; next }
    !replacing { print }
  ' "${pointer_asset}" "${merged_tmp}" > "${instruction_tmp}"
else
  awk '1' "${merged_tmp}" > "${instruction_tmp}"
  append_section "${instruction_tmp}" "${pointer_asset}"
fi

policy_start='<!-- skrrt:policy -->'
policy_end='<!-- /skrrt:policy -->'

{
  printf '%s\n' "${policy_start}"
  awk '1' "${strategy_asset}"
  printf '%s\n' "${policy_end}"
} > "${policy_block_tmp}"

policy_start_count=0
policy_end_count=0

if [[ -f .agents/ship.md ]]; then
  policy_start_count="$(grep -cF "${policy_start}" .agents/ship.md || true)"
  policy_end_count="$(grep -cF "${policy_end}" .agents/ship.md || true)"
fi

if [[ "${policy_start_count}" -gt 1 || "${policy_end_count}" -gt 1 ||
  "${policy_start_count}" -ne "${policy_end_count}" ]]; then
  printf 'STATUS=invalid-policy-markers FILE=.agents/ship.md\n' >&2
  exit 1
fi

# Replace only the managed block, so repository-specific rules written outside it survive a
# re-run. A policy file with no markers predates them and was generated whole, so it is
# replaced whole.
if [[ "${policy_start_count}" -eq 1 ]]; then
  awk -v start="${policy_start}" -v finish="${policy_end}" '
    FNR == NR { block = block $0 ORS; next }
    $0 == start { printf "%s", block; replacing = 1; next }
    replacing && $0 == finish { replacing = 0; next }
    !replacing { print }
  ' "${policy_block_tmp}" .agents/ship.md > "${policy_tmp}"
else
  awk '1' "${policy_block_tmp}" > "${policy_tmp}"
fi

instruction_status='unchanged'
policy_status='unchanged'

# Install the policy first. If this fails, the instruction file is left untouched and still
# points at the previous policy; the reverse order would publish a pointer to a stale one.
if [[ ! -f .agents/ship.md ]] || ! cmp -s "${policy_tmp}" .agents/ship.md; then
  mv "${policy_tmp}" .agents/ship.md
  policy_status='changed'
fi

if [[ ! -f "${instruction_file}" || -L "${instruction_file}" ]] ||
  ! cmp -s "${instruction_tmp}" "${instruction_file}"; then
  mv "${instruction_tmp}" "${instruction_file}"
  instruction_status='changed'
fi

for migrated in "${migrated_files[@]+"${migrated_files[@]}"}"; do
  rm -f "${migrated}"
done

printf 'STATUS=ok\n'
printf 'INSTRUCTION_FILE=%s\n' "${instruction_file}"
printf 'INSTRUCTION_STATUS=%s\n' "${instruction_status}"
for migrated in "${migrated_files[@]+"${migrated_files[@]}"}"; do
  printf 'MIGRATED_FILE=%s\n' "${migrated}"
done
if [[ -e CLAUDE.local.md ]]; then
  printf 'BLOCKING_FILE=CLAUDE.local.md\n'
fi
printf 'POLICY_FILE=.agents/ship.md\n'
printf 'POLICY_STATUS=%s\n' "${policy_status}"
printf 'STRATEGY=%s\n' "${strategy}"
