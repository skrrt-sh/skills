#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
detector="${repo_root}/skills/ship/pr/scripts/detect-forge-cli.sh"
test_dir="$(mktemp -d)"
cleanup() { rm -rf "${test_dir}"; }
trap cleanup EXIT

mkdir -p "${test_dir}/bin" "${test_dir}/repo"

cat > "${test_dir}/bin/gh" <<'SCRIPT'
#!/usr/bin/env bash
[[ "${FAKE_GH_AUTH:-0}" == '1' ]]
SCRIPT
cat > "${test_dir}/bin/glab" <<'SCRIPT'
#!/usr/bin/env bash
[[ "${FAKE_GLAB_AUTH:-0}" == '1' ]]
SCRIPT
chmod +x "${test_dir}/bin/gh" "${test_dir}/bin/glab"

cd "${test_dir}/repo"
git init -q
test_path="${test_dir}/bin:/usr/bin:/bin"

run_detector() {
  PATH="${test_path}" FAKE_GH_AUTH="${1}" FAKE_GLAB_AUTH="${2}" "${detector}"
}

git remote add origin git@github.com:owner/repo.git
output="$(run_detector 1 0)"
grep -Fq 'FORGE=github' <<< "${output}"
grep -Fq 'MATCHED_CLI=gh' <<< "${output}"
grep -Fq 'STATUS=ok' <<< "${output}"

if output="$(run_detector 0 0 2>&1)"; then
  printf 'unauthenticated GitHub CLI was accepted\n' >&2
  exit 1
fi
grep -Fq 'STATUS=not-authenticated' <<< "${output}"

git remote set-url origin https://gitlab.example.com/group/repo.git
output="$(run_detector 0 1)"
grep -Fq 'FORGE=gitlab' <<< "${output}"
grep -Fq 'MATCHED_CLI=glab' <<< "${output}"

git remote set-url origin ssh://git@code.example.test/group/repo.git
output="$(run_detector 1 0)"
grep -Fq 'FORGE=github' <<< "${output}"

if output="$(run_detector 1 1 2>&1)"; then
  printf 'ambiguous custom forge was accepted\n' >&2
  exit 1
fi
grep -Fq 'STATUS=ambiguous-remote' <<< "${output}"

git remote set-url origin https://token@github.com/owner/repo.git
output="$(run_detector 1 0)"
if grep -Fq 'token@' <<< "${output}"; then
  printf 'remote credentials leaked\n' >&2
  exit 1
fi

printf 'forge detector tests passed\n'
