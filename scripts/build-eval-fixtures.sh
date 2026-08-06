#!/usr/bin/env bash
set -euo pipefail

# Build reproducible fixture repositories for the behavior eval scenarios.
# The eval prompts describe repository states (branches, dirty worktrees, merged
# PRs) rather than shipping files, so every run has to start from identical
# state or the results are not comparable between configurations.
#
# Usage: build-eval-fixtures.sh <destination-dir>

dest="${1:-}"
[[ -n "${dest}" ]] || { printf 'usage: build-eval-fixtures.sh <destination-dir>\n' >&2; exit 1; }

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"
mkdir -p "${dest}"
dest="$(cd "${dest}" && pwd)"

git_init() {
  git init -q "${1}"
  git -C "${1}" config user.email fixture@skrrt.test
  git -C "${1}" config user.name 'Fixture Author'
  git -C "${1}" config commit.gpgsign false
}

# Both the pre-rewrite and current ship skills must find their policy, or the
# baseline fails on missing configuration instead of on its actual behavior.
write_policy() {
  local repo="${1}" strategy="${2}"
  mkdir -p "${repo}/.agents"
  cp "${repo_root}/skills/ship/setup/assets/${strategy}.md" "${repo}/.agents/ship.md"
  {
    printf '# Fixture project\n\n'
    cat "${repo_root}/skills/ship/setup/assets/instruction-pointer.md"
    printf '\n<!-- skrrt:branching -->\n## Branching strategy\n\n'
    sed -n '3,$p' "${repo_root}/skills/ship/setup/assets/${strategy}.md"
    printf '<!-- /skrrt:branching -->\n'
  } > "${repo}/CLAUDE.md"
}

# --- commit-1: focused fix, unrelated draft must survive -------------------
r="${dest}/commit-1-focused-fix"
git_init "${r}"
write_policy "${r}" trunk-based
mkdir -p "${r}/scripts"
printf '#!/usr/bin/env bash\nset -euo pipefail\necho "validating $1"\nexit 0\n' > "${r}/scripts/validate-md.sh"
printf '# Fixture Project\n\nA sample project.\n' > "${r}/README.md"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: :tada: initial fixture'
git -C "${r}" switch -qc fix/markdown-validator
printf '#!/usr/bin/env bash\nset -euo pipefail\nif [[ -z "${1:-}" ]]; then\n  echo "usage: validate-md.sh <file>" >&2\n  exit 1\nfi\necho "validating $1"\nexit 0\n' > "${r}/scripts/validate-md.sh"
printf '# Fixture Project\n\nA sample project.\n\n## Draft: roadmap ideas\n\nRough notes, not ready to publish.\n' > "${r}/README.md"

# --- commit-2: dirty worktree sitting on a protected branch ----------------
r="${dest}/commit-2-protected-branch"
git_init "${r}"
write_policy "${r}" github-flow
mkdir -p "${r}/src"
printf 'export function login() {\n  return null\n}\n' > "${r}/src/auth.js"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: :tada: initial fixture'
printf 'export function login(user, token) {\n  if (!token) throw new Error("missing token")\n  return { user, token }\n}\n\nexport function logout() {\n  return true\n}\n' > "${r}/src/auth.js"

# --- commit-3: two unrelated intents on one branch -------------------------
r="${dest}/commit-3-split-intents"
git_init "${r}"
write_policy "${r}" trunk-based
mkdir -p "${r}/src" "${r}/.github/workflows"
printf 'export function search() {\n  return []\n}\n' > "${r}/src/search.js"
printf 'name: CI\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n' > "${r}/.github/workflows/ci.yml"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: :tada: initial fixture'
git -C "${r}" switch -qc feat/search
printf 'export function search(query, items) {\n  return items.filter((i) => i.includes(query))\n}\n\nexport function rankResults(results) {\n  return results.sort()\n}\n' > "${r}/src/search.js"
printf 'name: CI\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n      - uses: actions/setup-node@v4\n        with:\n          cache: npm\n' > "${r}/.github/workflows/ci.yml"

# --- commit-4: regression after an already-merged branch -------------------
r="${dest}/commit-4-merged-precedent"
git_init "${r}"
write_policy "${r}" github-flow
mkdir -p "${r}/src"
printf 'export function parse(input) {\n  return input.trim()\n}\n' > "${r}/src/parse.js"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: :tada: initial fixture'
git -C "${r}" switch -qc feat/parser-rewrite
printf 'export function parse(input) {\n  return input.split(",").map((s) => s.trim())\n}\n' > "${r}/src/parse.js"
git -C "${r}" commit -qam 'feat(parser): :sparkles: split on commas'
git -C "${r}" switch -q main
git -C "${r}" merge -q --no-ff feat/parser-rewrite -m 'feat(parser): :sparkles: merge PR #42'
git -C "${r}" branch -qD feat/parser-rewrite
printf 'export function parse(input) {\n  if (input === "") return []\n  return input.split(",").map((s) => s.trim())\n}\n' > "${r}/src/parse.js"

# --- md-writer-1: greenfield knowledge base --------------------------------
r="${dest}/mdw-1-greenfield"
git_init "${r}"
mkdir -p "${r}/docs"
printf '# Fixture Project\n\nNo documentation conventions yet.\n' > "${r}/README.md"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: initial fixture'

# --- md-writer-2: existing local convention to match -----------------------
r="${dest}/mdw-2-local-convention"
git_init "${r}"
mkdir -p "${r}/docs/api"
cat > "${r}/docs/api/errors.md" <<'DOC'
---
title: "Error responses"
owner: "platform-team"
last_reviewed: "2026-05-02"
---

# Error responses

> How the API reports failures.

## Status codes

| Code | Meaning |
| --- | --- |
| 400 | Malformed request |
| 401 | Missing or invalid credentials |
DOC
cat > "${r}/docs/api/pagination.md" <<'DOC'
---
title: "Pagination"
owner: "platform-team"
last_reviewed: "2026-04-18"
---

# Pagination

> How list endpoints page their results.

## Cursors

Every list endpoint returns an opaque `next_cursor`.
DOC
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: initial fixture'

# --- md-writer-3: established ADR structure to preserve --------------------
r="${dest}/mdw-3-adr-update"
git_init "${r}"
mkdir -p "${r}/docs/adr"
cat > "${r}/docs/adr/0012-cache.md" <<'DOC'
---
title: "0012 — Cache layer"
status: "proposed"
decision-date: "2026-06-11"
---

# 0012 — Cache layer

> Which cache backend the read path should use.

## Context

Read latency on the catalogue endpoint exceeds the 200ms budget at peak.

## Options considered

- In-process LRU
- Redis
- Memcached

## Decision

Pending.

## Consequences

Pending.
DOC
cat > "${r}/docs/adr/0011-queue.md" <<'DOC'
---
title: "0011 — Queue backend"
status: "accepted"
decision-date: "2026-05-20"
---

# 0011 — Queue backend

> Which queue the ingest path should use.

## Decision

SQS, for operational familiarity.
DOC
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: initial fixture'

# --- md-writer-4: validator cannot run -------------------------------------
r="${dest}/mdw-4-no-linter"
git_init "${r}"
mkdir -p "${r}/docs"
printf '# Fixture Project\n\nOperations documentation lives in docs/.\n' > "${r}/README.md"
git -C "${r}" add -A && git -C "${r}" commit -qm 'chore: initial fixture'

printf 'fixtures built in %s\n' "${dest}"
ls -1 "${dest}"
