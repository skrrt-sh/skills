#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
setup_script="${repo_root}/skills/ship/setup/scripts/configure-ship.sh"
test_dir="$(mktemp -d)"
cleanup() { rm -rf "${test_dir}"; }
trap cleanup EXIT

cd "${test_dir}"
git init -q
printf '# Existing instructions\n\nKeep this line.\n\n<!-- skrrt:branching -->\nOld policy.\n<!-- /skrrt:branching -->\n' > CLAUDE.md

"${setup_script}" --instruction-file CLAUDE.md --strategy github-flow >/dev/null
[[ "$(grep -cF '<!-- skrrt:ship -->' CLAUDE.md)" -eq 1 ]]
grep -Fq 'Keep this line.' CLAUDE.md
if grep -Fq 'skrrt:branching' CLAUDE.md; then
  printf 'legacy branching block remained after migration\n' >&2
  exit 1
fi
grep -Fq '<!-- skrrt:strategy:github-flow -->' .agents/ship.md

first_sum="$(cksum CLAUDE.md .agents/ship.md)"
"${setup_script}" --instruction-file CLAUDE.md --strategy github-flow >/dev/null
second_sum="$(cksum CLAUDE.md .agents/ship.md)"
[[ "${first_sum}" == "${second_sum}" ]]

"${setup_script}" --instruction-file CLAUDE.md --strategy trunk-based >/dev/null
[[ "$(grep -cF '<!-- skrrt:ship -->' CLAUDE.md)" -eq 1 ]]
grep -Fq 'Keep this line.' CLAUDE.md
grep -Fq '<!-- skrrt:strategy:trunk-based -->' .agents/ship.md
if grep -Fq 'github-flow' .agents/ship.md; then
  printf 'stale strategy remained after replacement\n' >&2
  exit 1
fi

printf '<!-- skrrt:ship -->\n' > AGENTS.md
if "${setup_script}" --instruction-file AGENTS.md --strategy gitflow >/dev/null 2>&1; then
  printf 'invalid markers were accepted\n' >&2
  exit 1
fi

printf 'setup tests passed\n'
