#!/usr/bin/env bash
set -euo pipefail

# Lists every shipped skill (one SKILL.md per skill), repo-root-relative and sorted.

REPO="$(cd "$(dirname "${0}")/.." && pwd)"

cd "${REPO}"
find skills -name SKILL.md -not -path '*/node_modules/*' | sort
