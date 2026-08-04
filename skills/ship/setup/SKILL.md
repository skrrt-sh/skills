---
name: setup
description: Adds skrrt skills instructions to the current project's CLAUDE.md or AGENTS.md so that commits, PRs, and releases use the ship plugin skills. Use this skill whenever the user wants to set up, configure, install, or wire skrrt skills into a project, add ship plugin instructions to agent config files, or ensure the team uses /commit /pr /release instead of raw git commands. Trigger even when the user says "set up this repo", "add skills to CLAUDE.md", or "configure the ship plugin".
argument-hint: "[options]"
user-invocable: true
---

# Ship Setup Skill

Append two marker-delimited blocks to the project's agent instruction file: the ship skills
block and a branching strategy block.

## Workflow

1. **Find the instruction file** — first of `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`,
   `.github/AGENTS.md`. Create `CLAUDE.md` in the project root if none exists.
2. **Append the ship block** unless `<!-- skrrt:ship -->` is already present.
3. **Recommend a branching strategy** unless `<!-- skrrt:branching -->` is already present.
   Read [reference/branching-strategies.md](reference/branching-strategies.md), gather the
   signals it lists from the actual repo, then present all three options with one marked as
   recommended and your reasoning stated. The user chooses; append the matching block.

   If the marker already exists, read the heading after it to report the configured strategy
   and offer to replace it. Replacing means swapping everything between
   `<!-- skrrt:branching -->` and `<!-- /skrrt:branching -->` inclusive.
4. **Report** which file changed and which blocks were added.

Extra environment tiers beyond dev/staging/production need no block edit — they are just more
`vX.Y.Z-<env>.N` tags, and CI parses the suffix to pick the target.

## Blocks

Append these verbatim, markers included.

```markdown
<!-- skrrt:ship -->
## Git workflow — skrrt skills

Use `/commit` for commits, `/pr` for pull and merge requests, and `/release` for releases —
prefixed `/skrrt:` when installed as a Claude Code plugin. Do not hand-write
`git commit`, `gh pr create`, `gh release create`, `glab mr create`, or `glab release create`.

Tags are annotated and immutable: `vX.Y.Z` production, `vX.Y.Z-rc.N` staging,
`vX.Y.Z-<env>.N` other tiers. A bad release means a new patch version, never a moved tag.
Build once and promote the same artifact — never rebuild from a tag. Dev needs no tag.
<!-- /skrrt:ship -->
```

### GitHub Flow

```markdown
<!-- skrrt:branching -->
## Branching strategy — GitHub Flow

- `main` is the only long-lived branch and is always deployable. Never commit to it directly.
- Work happens on short-lived `<type>/<description>` branches (`feat/add-auth`,
  `fix/login-redirect`, `docs/api-guide`); PRs always target `main` and CI runs on every PR.
- No `develop`, `release/*`, or `hotfix/*` branches.
- **Skrrt convention:** rebase onto `main` before opening a PR (`git pull --rebase origin main`);
  abort and ask for help if it will not resolve cleanly. Squash merge, so one PR is one commit.
- **Skrrt convention:** tag on `main` only — `vX.Y.Z-rc.N` promotes to staging, `vX.Y.Z` to
  production. Merges to `main` deploy to dev untagged. A failed RC gets fixes by PR and a new RC.
<!-- /skrrt:branching -->
```

### Trunk-Based Development

```markdown
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
```

### Gitflow

```markdown
<!-- skrrt:branching -->
## Branching strategy — Gitflow

- `develop` is the integration branch; `main` only receives merges from `release/*` or
  `hotfix/*`, and every one of those merges is tagged immediately.
- `feat/<description>` branches from `develop` and PRs back to `develop` — never to `main`.
- `release/<version>` is cut from `develop` for stabilization only (bug fixes, version bumps —
  no features), then merges to both `main` and `develop`.
- `hotfix/<description>` is cut from `main` and merges back to `main` plus `develop` — or into
  the active `release/*` branch if one exists.
- All merges into `main` and `develop` use `--no-ff`. Never rebase; Gitflow needs the merge
  topology. Sync feature branches with `git pull origin develop`.
- **Skrrt convention:** production tags (`vX.Y.Z`) go on `main` at the merge commit.
  `vX.Y.Z-rc.N` tags go on `release/*` as validation milestones — the release branch itself is
  the staging gate, deploying on every push. `develop` auto-deploys to dev.
<!-- /skrrt:branching -->
```

## Guardrails

- Only append (or replace a branching block) — never touch or reformat anything outside the
  skrrt markers, and never duplicate a block whose marker already exists.
- Create no file other than the instruction file.
- Always analyze the repo before recommending; never use a static default, and never keep an
  existing strategy just because it is in use. The user makes the final call.

## Task

Handle this request: $ARGUMENTS
