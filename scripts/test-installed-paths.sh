#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
test_dir="$(mktemp -d)"
cleanup() { rm -rf "${test_dir}"; }
trap cleanup EXIT

mkdir -p "${test_dir}/installed" "${test_dir}/project" "${test_dir}/bin"
ln -s "${repo_root}/skills/ship/setup" "${test_dir}/installed/setup"
ln -s "${repo_root}/skills/ship/pr" "${test_dir}/installed/pr"
ln -s "${repo_root}/skills/docs/md-writer" "${test_dir}/installed/md-writer"
ln -s "${repo_root}/skills/term/statusline" "${test_dir}/installed/statusline"

cat > "${test_dir}/bin/gh" <<'SCRIPT'
#!/usr/bin/env bash
[[ "${1:-}" == 'auth' && "${2:-}" == 'status' ]]
SCRIPT
chmod +x "${test_dir}/bin/gh"

cd "${test_dir}/project"
git init -q
git remote add origin git@github.com:owner/project.git
printf '# Project\n' > AGENTS.md

CLAUDE_SKILL_DIR="${test_dir}/installed/setup"
"${CLAUDE_SKILL_DIR}/scripts/configure-ship.sh" --strategy github-flow >/dev/null
grep -Fq '<!-- skrrt:ship -->' AGENTS.md
grep -Fq '<!-- skrrt:strategy:github-flow -->' .agents/ship.md

CLAUDE_SKILL_DIR="${test_dir}/installed/pr"
detector_output="$(PATH="${test_dir}/bin:/usr/bin:/bin" \
  "${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh")"
grep -Fq 'REMOTE_URL=git@github.com:owner/project.git' <<< "${detector_output}"
grep -Fq 'STATUS=ok' <<< "${detector_output}"

printf '%s\n' '---' 'title: "Guide"' 'description: "Test"' 'created: "2026-08-06"' \
  'updated: "2026-08-06"' 'status: "draft"' '---' '' '# Guide' '' '> Test.' > guide.md
CLAUDE_SKILL_DIR="${test_dir}/installed/md-writer"
"${CLAUDE_SKILL_DIR}/scripts/validate-md.sh" guide.md >/dev/null 2>&1

config_dir="${test_dir}/claude config"
mkdir -p "${config_dir}"
printf '{"statusLine":{"type":"command","command":"old"},"theme":"dark"}\n' > "${config_dir}/settings.json"
CLAUDE_SKILL_DIR="${test_dir}/installed/statusline"
statusline_output="$(CLAUDE_CONFIG_DIR="${config_dir}" \
  "${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh")"
grep -Fq 'PREVIOUS_STATUSLINE={"type":"command","command":"old"}' <<< "${statusline_output}"
jq -e '.theme == "dark"' "${config_dir}/settings.json" >/dev/null
printf '{"model":{"display_name":"Opus"},"cwd":"/"}' |
  sh -c "$(jq -r '.statusLine.command' "${config_dir}/settings.json")" | grep -Fq 'Opus'

printf 'installed-path tests passed\n'
