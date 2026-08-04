<!-- skrrt:ship -->
## Git workflow — skrrt skills

Use `/commit` for commits, `/pr` for pull and merge requests, and `/release` for releases —
prefixed `/ship:` when installed as a Claude Code plugin. Do not hand-write
`git commit`, `gh pr create`, `gh release create`, `glab mr create`, or `glab release create`.

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
- **Skrrt convention:** rebase onto `main` before opening a PR (`git pull --rebase origin main`);
  abort and ask for help if it will not resolve cleanly. Squash merge, so one PR is one commit.
  Trunk-Based itself leaves merge strategy to preference — these are house rules, kept identical
  to GitHub Flow's. They earn their keep here because `main` moves fastest under TBD, so a branch
  goes stale quickest, and continuous deployment makes a one-commit revert the fastest way out of
  a bad deploy.
- **Skrrt convention:** at most 3 active branches at a time.
- **Skrrt convention:** tag on `main` only. At high cadence tags are optional and every merge
  can ship; at weekly/monthly cadence use `vX.Y.Z-rc.N` for staging and `vX.Y.Z` for production.
<!-- /skrrt:branching -->

## Repository structure

This repo ships agent skills two ways. **Each bucket is its own Claude Code plugin**, so the
bucket name is the slash namespace — `/ship:commit`, `/docs:md-writer`. The
[`skills`](https://skills.sh) CLI discovers every `SKILL.md` in the repo by scanning (verified:
it ignores manifest skill arrays) and installs bare names — `/commit`, `/md-writer`. The root
`plugin.json` stays as the repo-wide declared inventory for tooling that reads it.

- `skills/ship/` — git shipping workflow: `commit`, `pr`, `release`, `setup`.
- `skills/docs/` — documentation tools: `md-writer`.

Each skill lives at `skills/<bucket>/<name>/SKILL.md` with its supporting files co-located
(`reference/`, `scripts/`, `config/`, `evals/`). There are no per-skill manifests and no
plugin-level hooks — a skill that needs a script bundles it under its own `scripts/` and
invokes it from `SKILL.md`.

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
`<bucket>--vX.Y.Z` — `ship--v4.0.0`, `docs--v1.0.0` — created with `claude plugin tag --push`
pointed at the bucket directory; it is both the plugin marker and the release of record. There
is no repo-wide `vX.Y.Z` tag any more: with two independently versioned plugins there is no
single number it could carry. Bump
`version` in that bucket's `plugin.json` through a PR before tagging, since it must be on the
tagged commit and `main` takes no direct commits. The root `plugin.json` version tracks the
skills.sh bundle and is not tagged. Always `git fetch origin --tags` before picking a version —
a stale local tag list will produce a number that is already taken.

Helper scripts: `scripts/list-skills.sh` lists every `SKILL.md`; `scripts/link-skills.sh` symlinks
each skill into `~/.claude/skills` for local use.
