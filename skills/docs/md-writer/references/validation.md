# Markdown validation

Run the validator command from `SKILL.md` in the target repository.

| Exit | Meaning | Response |
| --- | --- | --- |
| `0` | Clean or explicitly skipped meta file | Continue; note a reported skip |
| `1` | Bad invocation or linter execution failure | Report the error; do not claim validation |
| `2` | Remaining lint violations | Fix the reported lines and run again |
| `3` | No pinned local linter and no `npx` | Ask the user to install dependencies; do not claim validation |

The script prefers the skill's pinned local `markdownlint-cli2`, then the exact pinned version
through `npx`. The `npx` path may require network permission. A repository
`.markdownlint.json`, `.jsonc`, `.yaml`, or `.yml` takes precedence over the bundled default.

Auto-fixes can change whitespace, list markers, fences, tables, and final newlines. Re-read a file
when the script reports that it changed. Fix semantic or judgment-based findings manually.

The validator explicitly skips `.claude/` content and well-known repository meta files such as
README, CLAUDE, AGENTS, CONTRIBUTING, CHANGELOG, SECURITY, and license files. Do not treat a skip as
proof that linting ran.
