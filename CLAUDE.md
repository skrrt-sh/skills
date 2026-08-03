<!-- skrrt:ship -->
## Git workflow — skrrt skills

Use `/commit` for commits, `/pr` for pull and merge requests, and `/release` for releases.
Do not hand-write `git commit`, `gh pr create`, `gh release create`, `glab mr create`, or
`glab release create`.

Tags are annotated and immutable: `vX.Y.Z` production, `vX.Y.Z-rc.N` staging,
`vX.Y.Z-<env>.N` other tiers. A bad release means a new patch version, never a moved tag.
Build once and promote the same artifact — never rebuild from a tag. Dev needs no tag.
<!-- /skrrt:ship -->

<!-- skrrt:branching -->
## Branching strategy — Trunk-Based Development

- `main` is the only long-lived branch. Agents always work on short-lived
  `<type>/<description>` branches with PRs — never commit to `main` directly.
- Branches last under 2 days, ideally under 1, with one owner each. If a branch needs syncing
  it has lived too long.
- CI runs on every commit to `main`; a broken build is the top priority. Feature flags hide
  incomplete work — deploy is not release. No code freezes, no integration phases.
- Just-in-time `release/*` branches may be cut from `main`; fixes land on `main` first, then
  cherry-pick. No `develop` or `hotfix/*` branches.
- Merge strategy follows the forge setting — branches are too short-lived for it to matter.
- **Skrrt convention:** at most 3 active branches at a time.
- **Skrrt convention:** tag on `main` only. At high cadence tags are optional and every merge
  can ship; at weekly/monthly cadence use `vX.Y.Z-rc.N` for staging and `vX.Y.Z` for production.
<!-- /skrrt:branching -->

## Repository structure

This repo ships agent skills via the [`skills`](https://skills.sh) CLI, using the
single-manifest layout: one root `.claude-plugin/plugin.json` with a `skills` array, and a flat
`skills/` tree organized into buckets.

- `skills/ship/` — git shipping workflow: `commit`, `pr`, `release`, `setup`.
- `skills/docs/` — documentation tools: `md-writer`.

Each skill lives at `skills/<bucket>/<name>/SKILL.md` with its supporting files co-located
(`reference/`, `scripts/`, `config/`, `evals/`). There are no per-plugin manifests, no
`marketplace.json`, and no plugin-level hooks — a skill that needs a script bundles it under its own
`scripts/` and invokes it from `SKILL.md`.

When adding or renaming a skill, keep three places in sync:

1. The `skills` array in `.claude-plugin/plugin.json`.
2. The bucket's `README.md` (one linked line per skill).
3. The Skills section in the root `README.md`.

Helper scripts: `scripts/list-skills.sh` lists every `SKILL.md`; `scripts/link-skills.sh` symlinks
each skill into `~/.claude/skills` for local use.
