<!-- skrrt:ship -->
## Git workflow

Use the Skrrt ship skills for git work: `commit` for commits, `pr` for pull and merge requests,
`release` for releases. Never hand-write `git commit`, `gh pr create`, `gh release create`,
`glab mr create`, or `glab release create` instead. Reconfiguring the workflow is `/setup`, which
only the user can run.

Read `.agents/ship.md` before changing any git workflow state.
<!-- /skrrt:ship -->

## Repository structure

This repo ships agent skills two ways. **Each bucket is its own Claude Code plugin**, so the
bucket name is the slash namespace — `/ship:commit`, `/docs:md-writer`. The
[`skills`](https://skills.sh) CLI discovers every `SKILL.md` in the repo by scanning (verified:
it ignores manifest skill arrays) and installs bare names — `/commit`, `/md-writer`. The root
`plugin.json` stays as the repo-wide declared inventory for tooling that reads it.

- `skills/ship/` — git shipping workflow: `commit`, `pr`, `release`, `setup`.
- `skills/docs/` — documentation tools: `md-writer`.

Each skill lives at `skills/<bucket>/<name>/SKILL.md` with its supporting files co-located
(`references/`, `scripts/`, `assets/`, `agents/`, `config/`, `evals/`). There are no per-skill
manifests and no plugin-level hooks — a skill that needs a script bundles it under its own
`scripts/` and invokes it from `SKILL.md`.

Every skill must also carry `agents/openai.yaml` (Codex interface and invocation policy) and
`evals/evals.json` (at least three behavior cases); every model-invocable skill additionally
needs `evals/trigger-evals.json` (20+ queries, 8+ each way). `scripts/validate-skills.sh` fails
without them, and it also fails on any frontmatter key outside `name`, `description`, `allowed-tools`,
and `disable-model-invocation` — the Agent Skills spec subset plus one exception, so the skills
still package for claude.ai and the Skills API. `setup` is that exception: a run-once
configurator the user enters deliberately, so it sets `disable-model-invocation: true` and
`allow_implicit_invocation: false`. Every other skill stays model-invocable, because hiding one
drops its description from the agent's context and the agent then runs the raw `git`/`gh`/`glab`
command instead of the governed workflow. Side effects are gated by the permission rules in
`templates/claude-settings.json`, not by hiding skills. A skill that bundles scripts
pre-approves them with
`allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/<name>.sh:*)` and invokes them directly — no
`bash` prefix and no quotes, or the permission rule stops matching.

When adding or renaming a skill, keep four places in sync:

1. The `skills` array in `skills/<bucket>/.claude-plugin/plugin.json` — paths relative to the
   bucket (`./commit`), and they may not escape it.
2. The `skills` array in the root `.claude-plugin/plugin.json` — repo-relative paths
   (`./skills/ship/commit`), the repo-wide aggregate.
3. The bucket's `README.md` (one linked line per skill).
4. The Skills section in the root `README.md`.

`marketplace.json` lists buckets, not skills, so a new skill never touches it. A **new bucket**
does: add `skills/<bucket>/.claude-plugin/plugin.json` and a marketplace entry whose `source` is
`./skills/<bucket>`.

Each bucket versions and releases independently. A release carries one tag,
`<bucket>/vX.Y.Z` — `ship/v5.1.0`, `docs/v3.0.0`, `dev/v1.0.0` — created with `git tag -a` and
pushed; it is both the plugin marker and the release of record. Do not use `claude plugin tag`: it
only emits `<bucket>--vX.Y.Z`, which reads as a prerelease suffix rather than a scope. Since that
command also checked manifest and marketplace agreement, confirm by hand that the bucket's
`plugin.json` version matches the tag and that `marketplace.json` carries an entry whose `source`
points at that bucket; marketplace entries hold no version of their own. Every tag is stable — this
repo ships no alphas, betas, or release candidates. There
is no repo-wide `vX.Y.Z` tag any more: with three independently versioned plugins there is no
single number it could carry. Tags predating this convention keep the older `<bucket>--vX.Y.Z`
form. Bump
`version` in that bucket's `plugin.json` through a PR before tagging, since it must be on the
tagged commit and `main` takes no direct commits. The root `plugin.json` version tracks the
skills.sh bundle and is not tagged. Always `git fetch origin --tags` before picking a version —
a stale local tag list will produce a number that is already taken.

Helper scripts: `scripts/list-skills.sh` lists every skill, `scripts/link-skills.sh` links them into
`~/.claude/skills`, and `scripts/test-skills.sh` runs the public CI checks.
