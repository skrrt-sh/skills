# Branching Strategies Reference

> How the setup skill picks a branching strategy for a project. The three models themselves are
> standard — this file covers only the signals, the recommendation logic, and the Skrrt tagging
> overlay.

## Project Analysis Signals

Gather what is available; weight by what you actually find.

| Signal | How to check | What it suggests |
| --- | --- | --- |
| `develop` branch | `git branch -a \| grep develop` | Legacy Gitflow — only counts if actively used. An abandoned `develop` is a reason to migrate, not to keep Gitflow. |
| `release/*` / `hotfix/*` branches | `git branch -a \| grep -E 'release/\|hotfix/'` | Active Gitflow, if recent. Old merged branches are artifacts. |
| Stabilization pattern | Several fix/version-bump commits on `release/*` between cut and merge | A genuine stabilization phase → Gitflow. |
| CI/CD pipeline | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` | Mature CI enables TBD. No CI → GitHub Flow, and treat the environment rules as target state. |
| Feature flags | Flag config or SDK (LaunchDarkly, Unleash, GrowthBook, custom) | Enables TBD — incomplete work can ship hidden. |
| Contributor count | Distinct authors in `git log` | Solo/small team → GitHub Flow or TBD; Gitflow overhead rarely pays off. |
| Deploy frequency | Tag/release cadence | Daily/weekly → TBD or GitHub Flow. Monthly+ → GitHub Flow or Gitflow. |
| Consumers track `main` | Plugin, skill, or unpinned library | `main` must stay release-quality — GitHub Flow and TBD both guarantee that. |
| Monorepo | `packages/`, `apps/`, workspace config | Suits TBD. Independent per-service versions need tag prefixes (`api/v1.2.3`) or release tooling (changesets, release-please) before the `vX.Y.Z` convention applies. |
| Long-lived unmerged branches | Old branches in `git branch -a` | Workflow smell — recommend shorter branches. |

## Recommendation Logic

1. **Default to GitHub Flow.** Lowest overhead, works solo or in a team.
2. **Upgrade to TBD** when CI/CD is mature, feature flags exist, and deploys are frequent. TBD
   is GitHub Flow with tighter discipline, not a different model.
3. **Recommend Gitflow only** for a real stabilization need that CI gating cannot cover.
   GitHub Flow and TBD also keep `main` deployable — Gitflow's only edge is the dedicated
   stabilization branch.
4. **Recommend migrating off Gitflow** when `develop` exists but nothing stabilizes on
   `release/*`, or the team and deployment model are simple. Migration goes through review like
   any other change — `develop` may hold unreleased work: open a PR from `develop` to `main`,
   confirm CI and release readiness on it, merge, then delete `develop` and update any CI that
   references it. Never merge the branches locally and push.
5. **Never recommend Gitflow just because `develop` exists** — that is a signal to investigate.

## Tagging and Environment (Skrrt Convention)

An opinionated overlay applied on top of whichever strategy is chosen — not part of the
canonical models.

- **Deploy ≠ release.** Deploying puts code in an environment; feature flags decide what users
  see.
- **Build once, promote the same artifact.** Promote by content identity (SHA/checksum); never
  rebuild from a tag.
- **Tags are immutable and annotated.** A bad release gets a new patch version.
- **Format:** `v{MAJOR}.{MINOR}.{PATCH}[-{label}.{n}]` — `v1.2.3` production, `v1.2.3-rc.1`
  staging, `v1.2.3-qa.1` custom tiers. Lowercase dot-separated labels only; the `v` prefix is
  mandatory. One format per project, or CI matching and changelog tooling break.
- **Lower environments need no tags.** Dev deploys from HEAD on merge; per-PR previews are
  SHA-scoped and die with the PR.
- **Tag only from `main`** (Gitflow excepted: RC tags live on `release/*`). Keep tagged tiers
  minimal — most projects need at most one pre-production tier.
- **Fetch tags before deriving a version.** `git tag --list` and `git describe` read local refs,
  so a stale clone reports an old latest release and produces a colliding version.
- **A name-prefixed tag namespace is not a format inconsistency.** Per-plugin
  (`skrrt--v2.1.0`, via `claude plugin tag`) or per-service (`api/v1.2.3`) tags coexist
  with `vX.Y.Z`, because the `v[0-9]*` CI globs do not match them. Keep `vX.Y.Z` as the release
  of record and let the prefixed namespace serve its own tooling.

### CI triggers

| Event | Environment | Strategies |
| --- | --- | --- |
| PR opened/updated | Preview (optional) | All |
| Merge to `main` | Dev | GitHub Flow, TBD |
| Merge to `develop` | Dev | Gitflow |
| Push to `release/*` | Staging | Gitflow |
| Tag `vX.Y.Z-rc.N` | Staging | GitHub Flow, TBD |
| Tag `vX.Y.Z-<env>.N` | Custom tier | All |
| Tag `vX.Y.Z` | Production | All |
| `workflow_dispatch` | Operator's choice | All |

Manual dispatch complements the tag flow — use it to promote a commit outside the normal path,
validate a hotfix, or redeploy a known-good build after a rollback. Production still gets a tag
for auditability.

### Anti-patterns

| Anti-pattern | Instead |
| --- | --- |
| Environment branches (`deploy/staging`) | Promote one artifact through environments. |
| Moving or re-creating tags | Cut a new patch version. |
| Mixed tag formats (`v1.2.3`, `1.2.3`, `release-1.2.3`) | Enforce `vX.Y.Z[-label.N]` in CI. |
| Tagging feature branches | Tag `main` only (Gitflow RCs on `release/*`). |
| Tagging every environment | Tag milestone promotions only. |
