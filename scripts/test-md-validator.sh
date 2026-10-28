#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
validator="${repo_root}/skills/docs/md-writer/scripts/validate-md.sh"
test_dir="$(mktemp -d)"
cleanup() { rm -rf "${test_dir}"; }
trap cleanup EXIT

printf '# Guide\n\nText.' > "${test_dir}/guide.md"
"${validator}" "${test_dir}/guide.md" >/dev/null 2>&1
if [[ "$(tail -c 1 "${test_dir}/guide.md" | wc -l | tr -d ' ')" -ne 1 ]]; then
  printf 'validator did not add the final newline\n' >&2
  exit 1
fi

printf '# Changelog  \n' > "${test_dir}/CHANGELOG.md"
before="$(cksum < "${test_dir}/CHANGELOG.md")"
output="$("${validator}" "${test_dir}/CHANGELOG.md" 2>&1)"
after="$(cksum < "${test_dir}/CHANGELOG.md")"
[[ "${before}" == "${after}" ]]
grep -Fq 'skipping well-known meta file' <<< "${output}"

printf '# Readme\n\nText.' > "${test_dir}/README.md"
"${validator}" "${test_dir}/README.md" >/dev/null 2>&1
if [[ "$(tail -c 1 "${test_dir}/README.md" | wc -l | tr -d ' ')" -ne 1 ]]; then
  printf 'validator skipped README instead of linting it\n' >&2
  exit 1
fi

banner='<p align="center">Logo</p>'
printf '%s\n\nText.\n' "${banner}" > "${test_dir}/plan.md"
plan_exit=0
"${validator}" "${test_dir}/plan.md" >/dev/null 2>&1 || plan_exit=$?
if [[ "${plan_exit}" -ne 2 ]]; then
  printf 'validator did not flag a non-README file with no H1 (exit %s)\n' "${plan_exit}" >&2
  exit 1
fi

mkdir "${test_dir}/pkg"
printf '%s\n\n# Readme\n\nText.\n' "${banner}" > "${test_dir}/pkg/readme.md"
if ! "${validator}" "${test_dir}/pkg/readme.md" >/dev/null 2>&1; then
  printf 'validator rejected a README banner before the H1\n' >&2
  exit 1
fi

printf 'markdown validator tests passed\n'
