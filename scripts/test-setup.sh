#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
setup_script="${repo_root}/skills/ship/setup/scripts/configure-ship.sh"
test_dir="$(mktemp -d)"
cleanup() { rm -rf "${test_dir}"; }
trap cleanup EXIT

cd "${test_dir}"
git init -q
printf '# Existing instructions\n\nKeep this line.\n\n<!-- skrrt:branching -->\nOld policy.\n<!-- /skrrt:branching -->\n' > AGENTS.md

"${setup_script}" --strategy github-flow >/dev/null
[[ "$(grep -cF '<!-- skrrt:ship -->' AGENTS.md)" -eq 1 ]]
grep -Fq 'Keep this line.' AGENTS.md
if grep -Fq 'skrrt:branching' AGENTS.md; then
  printf 'legacy branching block remained after migration\n' >&2
  exit 1
fi
grep -Fq '<!-- skrrt:strategy:github-flow -->' .agents/ship.md

first_sum="$(cksum AGENTS.md .agents/ship.md)"
"${setup_script}" --strategy github-flow >/dev/null
second_sum="$(cksum AGENTS.md .agents/ship.md)"
[[ "${first_sum}" == "${second_sum}" ]]

"${setup_script}" --strategy trunk-based >/dev/null
[[ "$(grep -cF '<!-- skrrt:ship -->' AGENTS.md)" -eq 1 ]]
grep -Fq 'Keep this line.' AGENTS.md
grep -Fq '<!-- skrrt:strategy:trunk-based -->' .agents/ship.md
if grep -Fq 'github-flow' .agents/ship.md; then
  printf 'stale strategy remained after replacement\n' >&2
  exit 1
fi

valid_instructions="$(cat AGENTS.md)"
printf '<!-- skrrt:ship -->\n' > AGENTS.md
if "${setup_script}" --strategy gitflow >/dev/null 2>&1; then
  printf 'invalid markers were accepted\n' >&2
  exit 1
fi
printf '%s\n' "${valid_instructions}" > AGENTS.md

# Repository-specific rules live outside the managed block and must outlive a strategy change,
# so a repo whose release contract differs from the template can state it once.
# The rule names the outgoing strategy on purpose: a preserved repository rule may legitimately
# mention any strategy, so the stale-strategy check below has to read the managed block alone.
printf '\n## This repository\n\nRelease with bucket tags only, including under trunk-based.\n' >> .agents/ship.md
"${setup_script}" --strategy github-flow >/dev/null
grep -Fq 'Release with bucket tags only, including under trunk-based.' .agents/ship.md ||
  { printf 'repository-specific policy was clobbered\n' >&2; exit 1; }
grep -Fq '<!-- skrrt:strategy:github-flow -->' .agents/ship.md
[[ "$(grep -cF '<!-- skrrt:policy -->' .agents/ship.md)" -eq 1 ]]
managed_policy="$(sed -n '/<!-- skrrt:policy -->/,/<!-- \/skrrt:policy -->/p' .agents/ship.md)"
if grep -Fq 'trunk-based' <<<"${managed_policy}"; then
  printf 'stale strategy remained inside the managed block\n' >&2
  exit 1
fi

third_sum="$(cksum .agents/ship.md)"
"${setup_script}" --strategy github-flow >/dev/null
[[ "${third_sum}" == "$(cksum .agents/ship.md)" ]] ||
  { printf 'policy rewrite is not idempotent once repository rules exist\n' >&2; exit 1; }

printf '<!-- skrrt:policy -->\n' > .agents/ship.md
if "${setup_script}" --strategy gitflow >/dev/null 2>&1; then
  printf 'invalid policy markers were accepted\n' >&2
  exit 1
fi

fail() { printf '%s\n' "${1}" >&2; exit 1; }

migration_dir="${test_dir}/migration"
mkdir -p "${migration_dir}/.claude"
cd "${migration_dir}"
git init -q
printf '# Root rules\n\nUse pnpm.\n\n<!-- skrrt:ship -->\nOld pointer.\n<!-- /skrrt:ship -->\n' > CLAUDE.md
printf 'Nested rule.\n' > .claude/CLAUDE.md
printf '{}\n' > .claude/settings.json
printf 'Personal rule.\n' > CLAUDE.local.md
local_sum="$(cksum CLAUDE.local.md)"

output="$("${setup_script}" --strategy github-flow)"
[[ ! -e CLAUDE.md && ! -e .claude/CLAUDE.md ]] || fail 'migrated CLAUDE.md files remained'
[[ -f .claude/settings.json ]] || fail 'migration removed unrelated .claude files'
grep -Fq 'Use pnpm.' AGENTS.md || fail 'CLAUDE.md content was not migrated'
grep -Fq 'Nested rule.' AGENTS.md || fail '.claude/CLAUDE.md content was not migrated'
[[ "$(grep -cF '<!-- skrrt:ship -->' AGENTS.md)" -eq 1 ]] || fail 'migration duplicated the marker block'
if grep -Fq 'Old pointer.' AGENTS.md; then fail 'stale pointer survived migration'; fi
grep -Fq 'MIGRATED_FILE=CLAUDE.md' <<<"${output}"
grep -Fq 'MIGRATED_FILE=.claude/CLAUDE.md' <<<"${output}"
grep -Fq 'BLOCKING_FILE=CLAUDE.local.md' <<<"${output}"
[[ "${local_sum}" == "$(cksum CLAUDE.local.md)" ]] || fail 'CLAUDE.local.md was modified'

migrated_sum="$(cksum AGENTS.md .agents/ship.md)"
output="$("${setup_script}" --strategy github-flow)"
[[ "${migrated_sum}" == "$(cksum AGENTS.md .agents/ship.md)" ]] || fail 'migration is not idempotent'
if grep -Fq 'MIGRATED_FILE' <<<"${output}"; then fail 'second run reported a migration'; fi
[[ "${local_sum}" == "$(cksum CLAUDE.local.md)" ]] || fail 'CLAUDE.local.md was modified'

linked_dir="${test_dir}/linked"
mkdir -p "${linked_dir}"
cd "${linked_dir}"
git init -q
printf 'Shared rule.\n' > AGENTS.md
ln -s AGENTS.md CLAUDE.md
"${setup_script}" --strategy github-flow >/dev/null
[[ ! -e CLAUDE.md && ! -L CLAUDE.md ]] || fail 'CLAUDE.md symlink remained'
[[ "$(grep -cF 'Shared rule.' AGENTS.md)" -eq 1 ]] || fail 'symlinked content was duplicated'

self_import_dir="${test_dir}/self-import"
mkdir -p "${self_import_dir}"
cd "${self_import_dir}"
git init -q
printf '  @AGENTS.md  \n' > CLAUDE.md
"${setup_script}" --strategy github-flow >/dev/null
[[ ! -e CLAUDE.md ]] || fail 'self-importing CLAUDE.md remained'
if grep -Fq '@AGENTS.md' AGENTS.md; then fail 'AGENTS.md imports itself'; fi

imports_dir="${test_dir}/imports"
mkdir -p "${imports_dir}/.claude"
cd "${imports_dir}"
git init -q
printf 'Shared rule.\n' > AGENTS.md
# The backticks are literal Markdown code spans.
# shellcheck disable=SC2016
printf '%s\n' 'See @rules.md' 'See @./other.md and @../docs/a.md' 'See @/abs/x.md' 'See @~/y.md' \
  'Run `see @code.md` first' '```' '@fenced.md' '```' '@../AGENTS.md' > .claude/CLAUDE.md
"${setup_script}" --strategy github-flow >/dev/null
[[ ! -e .claude/CLAUDE.md ]] || fail '.claude/CLAUDE.md remained'
# shellcheck disable=SC2016
for expected in 'See @.claude/rules.md' 'See @.claude/other.md and @docs/a.md' 'See @/abs/x.md' \
  'See @~/y.md' 'Run `see @code.md` first' '@fenced.md'; do
  grep -Fxq "${expected}" AGENTS.md || fail "import line missing after rebasing: ${expected}"
done
if grep -Fq '@AGENTS.md' AGENTS.md; then fail 'rebased import made AGENTS.md import itself'; fi

# The fake HOME is the parent itself, so its user-scope file must be skipped while the
# project-style CLAUDE.md beside it is reported.
ancestor_dir="${test_dir}/ancestor"
mkdir -p "${ancestor_dir}/.claude" "${ancestor_dir}/repo"
printf 'Parent rule.\n' > "${ancestor_dir}/CLAUDE.md"
printf 'User rule.\n' > "${ancestor_dir}/.claude/CLAUDE.md"
cd "${ancestor_dir}/repo"
git init -q
output="$(HOME="${ancestor_dir}" "${setup_script}" --strategy github-flow)"
ancestor_physical="$(cd "${ancestor_dir}" && pwd -P)"
grep -Fxq "BLOCKING_FILE=${ancestor_physical}/CLAUDE.md" <<<"${output}" ||
  fail 'ancestor CLAUDE.md was not reported'
if grep -Fq "BLOCKING_FILE=${ancestor_physical}/.claude/CLAUDE.md" <<<"${output}"; then
  fail 'user-scope CLAUDE.md was reported as blocking'
fi
[[ -f "${ancestor_dir}/CLAUDE.md" ]] || fail 'ancestor CLAUDE.md was touched'

printf 'setup tests passed\n'
