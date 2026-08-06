#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
cd "${repo_root}"

fail() {
  printf 'error: %s\n' "${1}" >&2
  exit 1
}

# Emit a manifest's declared skill paths, normalized and sorted, so they can be compared as a
# set against what discovery found. Rejects paths that are absolute, escape the manifest
# directory, or repeat — a duplicate entry would otherwise let the count check pass while a
# real skill goes undeclared.
manifest_skill_paths() {
  local manifest="${1}" label="${2}" declared normalized

  [[ "$(jq '.skills | length' "${manifest}")" -gt 0 ]] || fail "${label}: manifest declares no skills"
  declared="$(jq -r '.skills[]' "${manifest}")"

  while IFS= read -r entry; do
    [[ -n "${entry}" ]] || fail "${label}: empty skill path"
    [[ "${entry}" != /* ]] || fail "${label}: absolute skill path ${entry}"
    case "/${entry}/" in
      */../*) fail "${label}: skill path escapes the manifest directory: ${entry}" ;;
    esac
  done <<< "${declared}"

  normalized="$(printf '%s\n' "${declared}" | sed 's|^\./||')"
  [[ "$(printf '%s\n' "${normalized}" | wc -l)" -eq "$(printf '%s\n' "${normalized}" | sort -u | wc -l)" ]] ||
    fail "${label}: duplicate skill paths"

  printf '%s\n' "${normalized}" | sort
}

skill_count=0
discovered_skills=()

while IFS= read -r skill_md; do
  skill_count=$((skill_count + 1))
  skill_dir="$(dirname "${skill_md}")"
  discovered_skills+=("${skill_dir}")
  folder_name="$(basename "${skill_dir}")"

  [[ "$(sed -n '1p' "${skill_md}")" == '---' ]] || fail "${skill_md}: missing frontmatter"
  closing_line="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "${skill_md}")"
  [[ -n "${closing_line}" ]] || fail "${skill_md}: unclosed frontmatter"

  name="$(sed -n "2,$((closing_line - 1))p" "${skill_md}" | awk -F ': *' '$1 == "name" { print $2 }')"
  description="$(sed -n "2,$((closing_line - 1))p" "${skill_md}" | awk -F ': *' '$1 == "description" { sub(/^[^:]*:[[:space:]]*/, ""); print }')"

  [[ "${name}" == "${folder_name}" ]] || fail "${skill_md}: name must match folder"
  [[ "${name}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "${skill_md}: invalid name"
  [[ -n "${description}" ]] || fail "${skill_md}: missing description"
  [[ "${#description}" -le 1024 ]] || fail "${skill_md}: description exceeds 1024 characters"

  # Frontmatter stays inside the Agent Skills spec, apart from the one deliberate exception
  # below, so these skills also package for claude.ai, the Skills API, and package_skill.py.
  # Other Claude Code-only keys such as argument-hint and user-invocable are rejected.
  while IFS= read -r key; do
    case "${key}" in
      name | description | allowed-tools | disable-model-invocation) ;;
      *) fail "${skill_md}: unsupported frontmatter key ${key}" ;;
    esac
  done < <(sed -n "2,$((closing_line - 1))p" "${skill_md}" | awk -F: '/^[a-z][a-z0-9-]*:/ { print $1 }')

  words="$(wc -w < "${skill_md}" | tr -d ' ')"
  lines="$(wc -l < "${skill_md}" | tr -d ' ')"
  [[ "${words}" -le 800 ]] || fail "${skill_md}: ${words} words exceeds the 800-word project budget"
  [[ "${lines}" -le 200 ]] || fail "${skill_md}: ${lines} lines exceeds the 200-line project budget"

  [[ -f "${skill_dir}/agents/openai.yaml" ]] || fail "${skill_dir}: missing agents/openai.yaml"
  grep -Fq "\$${name}" "${skill_dir}/agents/openai.yaml" ||
    fail "${skill_dir}/agents/openai.yaml: default prompt must name \$${name}"

  # `setup` is a run-once configurator the user enters deliberately, so it stays hidden. Every
  # other skill stays model-invocable: hiding one drops its description from the agent's
  # context, so the agent runs the raw git or forge command instead of the governed workflow.
  # Side effects are gated at the permission layer (templates/claude-settings.json).
  if [[ "${name}" == 'setup' ]]; then
    grep -Fq 'disable-model-invocation: true' "${skill_md}" ||
      fail "${skill_md}: setup must stay explicit-only"
    grep -Fq 'allow_implicit_invocation: false' "${skill_dir}/agents/openai.yaml" ||
      fail "${skill_dir}/agents/openai.yaml: setup must stay explicit-only"
  else
    if sed -n "2,$((closing_line - 1))p" "${skill_md}" | grep -q '^disable-model-invocation:'; then
      fail "${skill_md}: only setup may be hidden from the model"
    fi
    grep -Fq 'allow_implicit_invocation: true' "${skill_dir}/agents/openai.yaml" ||
      fail "${skill_dir}/agents/openai.yaml: skills must allow implicit invocation"

    # A model-invocable skill routes on its description, so it must prove the description
    # attracts its own requests and rejects the neighbouring skills' requests.
    [[ -f "${skill_dir}/evals/trigger-evals.json" ]] ||
      fail "${skill_dir}: model-invocable skills need evals/trigger-evals.json"
    jq -e 'type == "array" and length >= 20 and
      ([.[] | select(.should_trigger == true)] | length >= 8) and
      ([.[] | select(.should_trigger == false)] | length >= 8) and
      all(.[]; (.query | type == "string" and length > 0) and (.should_trigger | type == "boolean"))' \
      "${skill_dir}/evals/trigger-evals.json" >/dev/null ||
      fail "${skill_dir}: invalid trigger eval schema"
  fi

  [[ -f "${skill_dir}/evals/evals.json" ]] || fail "${skill_dir}: missing evals/evals.json"
  jq -e --arg name "${name}" '
    .skill_name == $name and
    (.evals | type == "array" and length >= 3) and
    all(.evals[];
      (.id | type == "number") and
      (.prompt | type == "string" and length > 0) and
      (.expected_output | type == "string" and length > 0) and
      (.assertions | type == "array" and length > 0) and
      all(.assertions[]; type == "string" and length > 0) and
      ((has("files") | not) or
        (.files | type == "array" and all(.[]; type == "string")))
    )
  ' "${skill_dir}/evals/evals.json" >/dev/null || fail "${skill_dir}: invalid Agent Skills eval schema"

  while IFS= read -r target; do
    case "${target}" in
      http://* | https://* | \#*) continue ;;
    esac
    [[ "${target}" != *' '* ]] || fail "${skill_md}: linked paths may not contain spaces"
    [[ -e "${skill_dir}/${target}" ]] || fail "${skill_md}: missing linked resource ${target}"
  done < <(sed -n 's/.*](\([^)]*\)).*/\1/p' "${skill_md}")
done < <(find skills -name SKILL.md -not -path '*/node_modules/*' | sort)

[[ "${skill_count}" -gt 0 ]] || fail 'no skills found'

discovered_root="$(printf '%s\n' "${discovered_skills[@]}" | sort)"
declared_root="$(manifest_skill_paths .claude-plugin/plugin.json 'root plugin manifest')"
[[ "${declared_root}" == "${discovered_root}" ]] || {
  diff <(printf '%s\n' "${discovered_root}") <(printf '%s\n' "${declared_root}") >&2 || true
  fail 'root plugin manifest does not declare exactly the discovered skills'
}

for bucket in skills/*; do
  [[ -d "${bucket}" && -f "${bucket}/.claude-plugin/plugin.json" ]] || continue
  discovered_bucket="$(printf '%s\n' "${discovered_skills[@]}" | sed -n "s|^${bucket}/||p" | sort)"
  declared_bucket="$(manifest_skill_paths "${bucket}/.claude-plugin/plugin.json" "${bucket}")"
  [[ "${declared_bucket}" == "${discovered_bucket}" ]] || {
    diff <(printf '%s\n' "${discovered_bucket}") <(printf '%s\n' "${declared_bucket}") >&2 || true
    fail "${bucket}: plugin manifest does not declare exactly the skills in this bucket"
  }
done

if rg -n '<skill-root>|from this skill directory|^user-invocable:|^argument-hint:' skills -g 'SKILL.md'; then
  fail 'found guessed skill paths or redundant frontmatter'
fi

claude_skill_script_token="\${CLAUDE_SKILL_DIR}/scripts/"
while IFS= read -r skill_dir; do
  grep -Fq "${claude_skill_script_token}" "${skill_dir}/SKILL.md" ||
    fail "${skill_dir}/SKILL.md: bundled scripts must use the documented Claude skill path variable"
  # The skill body invokes bundled scripts directly so the allowed-tools rule matches, which
  # only works while every script stays executable.
  grep -Fq "allowed-tools: Bash(${claude_skill_script_token}" "${skill_dir}/SKILL.md" ||
    fail "${skill_dir}/SKILL.md: bundled scripts must be pre-approved through allowed-tools"
  while IFS= read -r bundled_script; do
    [[ -x "${bundled_script}" ]] || fail "${bundled_script}: bundled scripts must be executable"
  done < <(find "${skill_dir}/scripts" -name '*.sh' -type f)
done < <(find skills -type d -name scripts -not -path '*/node_modules/*' -exec dirname {} \; | sort)

find scripts skills -name '*.sh' -not -path '*/node_modules/*' -print0 |
  while IFS= read -r -d '' script; do bash -n "${script}"; done

find skills -path '*/evals/*.json' -type f -print0 |
  while IFS= read -r -d '' eval_file; do jq empty "${eval_file}"; done

cmp -s skills/ship/pr/scripts/detect-forge-cli.sh skills/ship/release/scripts/detect-forge-cli.sh ||
  fail 'forge detectors must remain identical'

jq -e '.schema_version == 1 and .suite == "ship-integration" and (.evals | length >= 3)' \
  skills/ship/evals/integration.json >/dev/null || fail 'invalid ship integration eval schema'

printf 'validated %s skills\n' "${skill_count}"
