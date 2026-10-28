<!-- skrrt:ship -->
## Git workflow

Use the Skrrt ship skills for git work: `commit` for commits, `pr` for pull and merge requests,
`release` for releases. Never hand-write `git commit`, `gh pr create`, `gh release create`,
`glab mr create`, or `glab release create` instead. Reconfiguring the workflow is `/setup`, which
only the user can run.

Read `.agents/ship.md` before changing any git workflow state.
<!-- /skrrt:ship -->

## Skill conventions

Each skill lives at `skills/<bucket>/<name>/SKILL.md` with its supporting files co-located
(`references/`, `scripts/`, `assets/`, `agents/`, `config/`, `evals/`). There are no per-skill
manifests and no plugin-level hooks: a skill that needs a script bundles it under its own
`scripts/` and invokes it from `SKILL.md`.

Every skill must also carry `agents/openai.yaml` (Codex interface and invocation policy) and
`evals/evals.json` (at least three behavior cases); every model-invocable skill additionally
needs `evals/trigger-evals.json` (20+ queries, 8+ each way). `scripts/validate-skills.sh` fails
without them, and it also fails on any frontmatter key outside `name`, `description`, `allowed-tools`,
and `disable-model-invocation`. Only `setup` sets `disable-model-invocation: true` and
`allow_implicit_invocation: false`; every other skill stays model-invocable. Gate side effects with
the permission rules in `templates/claude-settings.json`. A skill that bundles scripts pre-approves
them with `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/<name>.sh:*)` and invokes them directly,
with no `bash` prefix and no quotes.

When adding or renaming a skill, keep four places in sync:

1. The `skills` array in `skills/<bucket>/.claude-plugin/plugin.json`: paths relative to the
   bucket (`./commit`), and they may not escape it.
2. The `skills` array in the root `.claude-plugin/plugin.json`: repo-relative paths
   (`./skills/ship/commit`), the repo-wide aggregate.
3. The bucket's `README.md` (one linked line per skill).
4. The Skills section in the root `README.md`.

`marketplace.json` lists buckets, not skills, so a new skill never touches it. A **new bucket**
does: add `skills/<bucket>/.claude-plugin/plugin.json` and a marketplace entry whose `source` is
`./skills/<bucket>`.

Helper scripts: `scripts/list-skills.sh` lists every skill, `scripts/link-skills.sh` links them into
`~/.claude/skills`, and `scripts/test-skills.sh` runs the public CI checks.
