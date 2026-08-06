#!/usr/bin/env bash
set -euo pipefail

# Detect the remote forge, matching CLI, and authentication state.
# Usage: detect-forge-cli.sh [remote-name]

remote_name="${1:-origin}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  printf 'STATUS=not-a-git-repo\n'
  exit 1
fi

if ! remote_url="$(git remote get-url "${remote_name}" 2>/dev/null)"; then
  printf 'REMOTE_NAME=%s\n' "${remote_name}"
  printf 'STATUS=no-remote\n'
  exit 1
fi

safe_remote_url="${remote_url}"
case "${remote_url}" in
  http://*@* | https://*@*)
    scheme="${remote_url%%://*}://"
    authority_and_path="${remote_url#*://}"
    safe_remote_url="${scheme}${authority_and_path#*@}"
    ;;
  *) ;;
esac

remote_host='unknown'
case "${remote_url}" in
  ssh://* | http://* | https://*)
    authority="${remote_url#*://}"
    authority="${authority%%/*}"
    authority="${authority#*@}"
    remote_host="${authority%%:*}"
    ;;
  *:*)
    authority="${remote_url%%:*}"
    remote_host="${authority#*@}"
    ;;
  *) ;;
esac

forge='unknown'
case "${remote_host}" in
  github.com | *.github.com | github.* | *.github.*) forge='github' ;;
  gitlab.com | *.gitlab.com | gitlab.* | *.gitlab.*) forge='gitlab' ;;
  *) ;;
esac

gh_available=0
glab_available=0
gh_authenticated=0
glab_authenticated=0

command -v gh >/dev/null 2>&1 && gh_available=1
command -v glab >/dev/null 2>&1 && glab_available=1

if [[ "${gh_available}" -eq 1 ]] && gh auth status --hostname "${remote_host}" >/dev/null 2>&1; then
  gh_authenticated=1
fi
if [[ "${glab_available}" -eq 1 ]] && glab auth status --hostname "${remote_host}" >/dev/null 2>&1; then
  glab_authenticated=1
fi

matched_cli='none'
auth_status='not-checked'
status='unknown-remote'

case "${forge}" in
  github)
    if [[ "${gh_available}" -eq 0 ]]; then
      status='no-compatible-cli'
    elif [[ "${gh_authenticated}" -eq 0 ]]; then
      matched_cli='gh'
      auth_status='not-authenticated'
      status='not-authenticated'
    else
      matched_cli='gh'
      auth_status='ok'
      status='ok'
    fi
    ;;
  gitlab)
    if [[ "${glab_available}" -eq 0 ]]; then
      status='no-compatible-cli'
    elif [[ "${glab_authenticated}" -eq 0 ]]; then
      matched_cli='glab'
      auth_status='not-authenticated'
      status='not-authenticated'
    else
      matched_cli='glab'
      auth_status='ok'
      status='ok'
    fi
    ;;
  unknown)
    if [[ "${gh_authenticated}" -eq 1 && "${glab_authenticated}" -eq 0 ]]; then
      forge='github'
      matched_cli='gh'
      auth_status='ok'
      status='ok'
    elif [[ "${glab_authenticated}" -eq 1 && "${gh_authenticated}" -eq 0 ]]; then
      forge='gitlab'
      matched_cli='glab'
      auth_status='ok'
      status='ok'
    elif [[ "${gh_authenticated}" -eq 1 && "${glab_authenticated}" -eq 1 ]]; then
      auth_status='ambiguous'
      status='ambiguous-remote'
    fi
    ;;
esac

printf 'REMOTE_NAME=%s\n' "${remote_name}"
printf 'REMOTE_URL=%s\n' "${safe_remote_url}"
printf 'REMOTE_HOST=%s\n' "${remote_host}"
printf 'FORGE=%s\n' "${forge}"
printf 'MATCHED_CLI=%s\n' "${matched_cli}"
printf 'AUTH_STATUS=%s\n' "${auth_status}"
printf 'STATUS=%s\n' "${status}"

[[ "${status}" == 'ok' ]]
