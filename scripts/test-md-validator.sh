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

printf '# Readme  \n' > "${test_dir}/README.md"
before="$(cksum < "${test_dir}/README.md")"
output="$("${validator}" "${test_dir}/README.md" 2>&1)"
after="$(cksum < "${test_dir}/README.md")"
[[ "${before}" == "${after}" ]]
grep -Fq 'skipping well-known meta file' <<< "${output}"

printf 'markdown validator tests passed\n'
