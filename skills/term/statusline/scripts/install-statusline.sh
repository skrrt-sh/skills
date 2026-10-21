#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'error: %s\n' "${1}" >&2
  exit 1
}

budget="${1:-256000}"
[[ "${budget}" =~ ^[1-9][0-9]*$ ]] || fail "budget must be a positive token count, got '${budget}'"

command -v python3 >/dev/null || fail 'python3 is required'
command -v jq >/dev/null || fail 'jq is required'

skill_dir="$(cd "$(dirname "${0}")/.." && pwd)"
config_dir="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
target="${config_dir}/statusline/statusline.py"
settings="${config_dir}/settings.json"

# Installed outside the plugin cache, whose versioned path changes on every plugin update.
mkdir -p "$(dirname "${target}")"
if [[ -f "${target}" ]] && ! cmp -s "${skill_dir}/assets/statusline.py" "${target}"; then
  backup="${target}.$(date +%Y%m%d%H%M%S).bak"
  cp -p "${target}" "${backup}"
  printf 'BACKUP=%s\n' "${backup}"
fi
cp "${skill_dir}/assets/statusline.py" "${target}"
chmod +x "${target}"

[[ -f "${settings}" ]] || printf '{}\n' > "${settings}"
previous="$(jq -c '.statusLine // empty' "${settings}")"
[[ -z "${previous}" ]] || printf 'PREVIOUS_STATUSLINE=%s\n' "${previous}"
updated="$(mktemp)"
# statusLine.command runs through a shell, so a config path with spaces must stay one word.
jq --arg cmd "${target}" --arg budget "${budget}" \
  '.statusLine = {type: "command", command: "\($cmd | @sh) \($budget)", padding: 0}' \
  "${settings}" > "${updated}"
mv "${updated}" "${settings}"

printf 'INSTALLED=%s\nSETTINGS=%s\nBUDGET=%s\n' "${target}" "${settings}" "${budget}"
