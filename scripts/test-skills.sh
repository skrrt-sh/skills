#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${0}")/.." && pwd)"

"${repo_root}/scripts/validate-skills.sh"
"${repo_root}/scripts/test-setup.sh"
"${repo_root}/scripts/test-forge-detector.sh"
"${repo_root}/scripts/test-md-validator.sh"
"${repo_root}/scripts/test-installed-paths.sh"
npm --prefix "${repo_root}/skills/docs/md-writer" run lint

printf 'all skill tests passed\n'
