#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: configure-ship.sh --instruction-file <path> --strategy <github-flow|trunk-based|gitflow>\n' >&2
}

instruction_file=''
strategy=''

while [[ "$#" -gt 0 ]]; do
  case "${1}" in
    --instruction-file)
      instruction_file="${2:-}"
      shift 2
      ;;
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

case "${instruction_file}" in
  CLAUDE.md | AGENTS.md | .claude/CLAUDE.md | .github/AGENTS.md) ;;
  *)
    usage
    exit 1
    ;;
esac

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
mkdir -p "$(dirname "${instruction_file}")" .agents

instruction_tmp="$(mktemp "${instruction_file}.tmp.XXXXXX")"
normalized_tmp="$(mktemp "${instruction_file}.normalized.XXXXXX")"
policy_tmp="$(mktemp '.agents/ship.md.tmp.XXXXXX')"
policy_block_tmp="$(mktemp '.agents/ship.md.block.XXXXXX')"
cleanup() {
  rm -f "${instruction_tmp}" "${normalized_tmp}" "${policy_tmp}" "${policy_block_tmp}"
}
trap cleanup EXIT

start_marker='<!-- skrrt:ship -->'
end_marker='<!-- /skrrt:ship -->'
start_count=0
end_count=0

if [[ -f "${instruction_file}" ]]; then
  start_count="$(grep -cF "${start_marker}" "${instruction_file}" || true)"
  end_count="$(grep -cF "${end_marker}" "${instruction_file}" || true)"
fi

if [[ "${start_count}" -gt 1 || "${end_count}" -gt 1 || "${start_count}" -ne "${end_count}" ]]; then
  printf 'STATUS=invalid-markers FILE=%s\n' "${instruction_file}" >&2
  exit 1
fi

if [[ "${start_count}" -eq 0 ]]; then
  if [[ -s "${instruction_file}" ]]; then
    awk '1; END { print "" }' "${instruction_file}" > "${instruction_tmp}"
  fi
  awk '1' "${pointer_asset}" >> "${instruction_tmp}"
else
  awk -v start="${start_marker}" -v finish="${end_marker}" '
    FNR == NR { block = block $0 ORS; next }
    $0 == start { printf "%s", block; replacing = 1; next }
    replacing && $0 == finish { replacing = 0; next }
    !replacing { print }
  ' "${pointer_asset}" "${instruction_file}" > "${instruction_tmp}"
fi

legacy_start='<!-- skrrt:branching -->'
legacy_end='<!-- /skrrt:branching -->'
legacy_start_count="$(grep -cF "${legacy_start}" "${instruction_tmp}" || true)"
legacy_end_count="$(grep -cF "${legacy_end}" "${instruction_tmp}" || true)"

if [[ "${legacy_start_count}" -gt 1 || "${legacy_end_count}" -gt 1 ||
  "${legacy_start_count}" -ne "${legacy_end_count}" ]]; then
  printf 'STATUS=invalid-legacy-markers FILE=%s\n' "${instruction_file}" >&2
  exit 1
fi

if [[ "${legacy_start_count}" -eq 1 ]]; then
  awk -v start="${legacy_start}" -v finish="${legacy_end}" '
    $0 == start { removing = 1; next }
    removing && $0 == finish { removing = 0; next }
    !removing { print }
  ' "${instruction_tmp}" > "${normalized_tmp}"
else
  awk '1' "${instruction_tmp}" > "${normalized_tmp}"
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

if [[ ! -f "${instruction_file}" ]] || ! cmp -s "${normalized_tmp}" "${instruction_file}"; then
  mv "${normalized_tmp}" "${instruction_file}"
  instruction_status='changed'
fi

printf 'STATUS=ok\n'
printf 'INSTRUCTION_FILE=%s\n' "${instruction_file}"
printf 'INSTRUCTION_STATUS=%s\n' "${instruction_status}"
printf 'POLICY_FILE=.agents/ship.md\n'
printf 'POLICY_STATUS=%s\n' "${policy_status}"
printf 'STRATEGY=%s\n' "${strategy}"
