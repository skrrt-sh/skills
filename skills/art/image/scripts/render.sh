#!/usr/bin/env bash
set -euo pipefail

# Render one Higgsfield image job with the CLI, or serve the connector path's prompt, log and download.
# Usage: render.sh <model> <name> <prompt-file> <out-dir> [higgsfield flags...]
#        render.sh --cost <model> <prompt-file> [higgsfield flags...]
#        render.sh --prompt <prompt-file>
#        render.sh --log <model> <name> <job-id> <prompt-file> <out-dir> [params as flags...]
#        render.sh --fetch <name> <job-id> <result-url> <out-dir>

fail() {
  printf 'render: %s\n' "${1}" >&2
  exit 1
}

# The CLI rejects a prompt that is a bare JSON object, so a lead sentence goes first.
lead='Render the image described by this JSON specification. Follow every field exactly.'

read_spec() {
  [[ -s "${1}" ]] || fail "prompt file ${1} is missing or empty"
  jq -cs 'if length == 1 and (.[0] | type) == "object" then .[0] else error end' "${1}" \
    2>/dev/null || fail "prompt file ${1} must hold exactly one JSON object"
}

prompt_for() {
  printf '%s\n%s' "${lead}" "${1}"
}

check_name() {
  [[ "${1}" =~ ^[A-Za-z0-9._-]+$ ]] || fail "name ${1} may only use letters, digits, dot, dash, underscore"
}

is_job_id() {
  [[ "${1}" =~ ^[0-9a-fA-F-]{36}$ ]]
}

# Higgsfield's history omits some models' jobs, so the id is logged before waiting on the job.
log_job() {
  local out_dir="${1}" job_id="${2}" model="${3}" name="${4}" spec="${5}"
  shift 5
  mkdir -p "${out_dir}"
  local record
  # One printf is one write, so parallel renders cannot split each other's records.
  record="$(jq -cn --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg job_id "${job_id}" --arg model "${model}" \
    --arg name "${name}" --argjson prompt "${spec}" \
    '{time: $time, job_id: $job_id, model: $model, name: $name, flags: $ARGS.positional, prompt: $prompt}' \
    --args -- "$@")"
  printf '%s\n' "${record}" >> "${out_dir}/jobs.jsonl"
}

fetch() {
  local out_dir="${1}" name="${2}" job_id="${3}" url="${4}" out
  out="${out_dir}/${name}__${job_id}.png"
  mkdir -p "${out_dir}"
  curl -sfL --connect-timeout 20 --max-time 300 --retry 3 --retry-delay 2 --retry-all-errors -o "${out}.part" "${url}" || {
    rm -f "${out}.part"
    fail "download failed for job ${job_id}: ${url}"
  }
  mv "${out}.part" "${out}"
  printf '%s\n' "${out}"
}

case "${1:-}" in
  --cost)
    [[ "${#}" -ge 3 ]] || fail 'usage: render.sh --cost <model> <prompt-file> [flags...]'
    model="${2}"
    spec="$(read_spec "${3}")"
    shift 3
    higgsfield generate cost "${model}" --prompt "$(prompt_for "${spec}")" "$@" --json | jq -r '.credits'
    exit 0
    ;;
  --prompt)
    [[ "${#}" -eq 2 ]] || fail 'usage: render.sh --prompt <prompt-file>'
    spec="$(read_spec "${2}")"
    printf '%s\n' "$(prompt_for "${spec}")"
    exit 0
    ;;
  --log)
    [[ "${#}" -ge 6 ]] || fail 'usage: render.sh --log <model> <name> <job-id> <prompt-file> <out-dir> [flags...]'
    check_name "${3}"
    is_job_id "${4}" || fail "job id ${4} is not a UUID"
    spec="$(read_spec "${5}")"
    model="${2}" name="${3}" job_id="${4}" out_dir="${6}"
    shift 6
    log_job "${out_dir}" "${job_id}" "${model}" "${name}" "${spec}" "$@"
    exit 0
    ;;
  --fetch)
    [[ "${#}" -eq 5 ]] || fail 'usage: render.sh --fetch <name> <job-id> <result-url> <out-dir>'
    check_name "${2}"
    is_job_id "${3}" || fail "job id ${3} is not a UUID"
    fetch "${5}" "${2}" "${3}" "${4}"
    exit 0
    ;;
  *) ;;
esac

[[ "${#}" -ge 4 ]] || fail 'usage: render.sh <model> <name> <prompt-file> <out-dir> [flags...]'
model="${1}"
name="${2}"
spec="$(read_spec "${3}")"
out_dir="${4}"
shift 4
check_name "${name}"
mkdir -p "${out_dir}"

submitted="$(higgsfield generate create "${model}" --prompt "$(prompt_for "${spec}")" "$@" --json)" ||
  fail "submit failed for ${name}"
job_id="$(jq -r 'if type == "array" then .[0] else . end
  | if type == "string" then . else (.job_ids[0]? // .id // .job_id // empty) end' \
  <<< "${submitted}" 2>/dev/null || true)"
# The submit output's shape is not documented, so an unknown shape falls back to its first UUID.
is_job_id "${job_id}" ||
  job_id="$(grep -Eo '[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}' <<< "${submitted}" | head -n 1 || true)"
is_job_id "${job_id}" || fail "no job id in submit output: ${submitted}"
log_job "${out_dir}" "${job_id}" "${model}" "${name}" "${spec}" "$@"

# Polls `generate get` rather than `generate wait`: a wait can hang locally while the job
# finishes on the server.
deadline=$((SECONDS + ${RENDER_TIMEOUT:-1200}))
while :; do
  job="$(higgsfield generate get "${job_id}" --json 2>/dev/null || true)"
  status="$(jq -r '.status // empty' <<< "${job}" 2>/dev/null || true)"
  case "${status}" in
    completed) break ;;
    failed | canceled | cancelled | nsfw | ip_detected) fail "job ${job_id} (${name}) ended ${status}" ;;
    *) ;;
  esac
  [[ "${SECONDS}" -lt "${deadline}" ]] ||
    fail "job ${job_id} (${name}) still ${status:-unknown}; recover later with: higgsfield generate get ${job_id} --json"
  sleep 5
done

url="$(jq -r '.result_url // empty' <<< "${job}")"
[[ -n "${url}" ]] || fail "job ${job_id} (${name}) completed without a result_url"
fetch "${out_dir}" "${name}" "${job_id}" "${url}"
