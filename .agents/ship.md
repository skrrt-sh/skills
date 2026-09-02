<!-- skrrt:policy -->
<!-- skrrt:strategy:trunk-based -->
# Ship workflow — Trunk-Based Development

- Protected branch: `main`. It is the only long-lived branch and must stay releasable.
- Work base: `main`. Use `<type>/<description>` branches lasting less than two days; keep at most
  three active branches.
- PR target: `main`. Rebase unpublished work onto `origin/main`; rewriting a published branch
  requires explicit approval and `--force-with-lease`.
- Merge: squash after required checks pass. A broken `main` is the highest-priority fix.
- Hide incomplete work with feature flags; deployment does not imply release.
- Just-in-time `release/*` branches may stabilize a release. Fix on `main` first, then cherry-pick.
- Releases: tag `main` with immutable annotated `vX.Y.Z` or `vX.Y.Z-rc.N` tags. High-cadence
  projects may release every merge without tagging lower environments.
- Build once and promote the same artifact by content identity.
<!-- /skrrt:policy -->

## This repository

The generic release rule above does not apply here. This repo ships three independently versioned
plugins, so there is no single number a repo-wide `vX.Y.Z` tag could carry.

- Release tags are bucket-scoped: exactly one `<bucket>@X.Y.Z` tag per release —
  `ship@5.2.0`, `docs@3.0.0`, `dev@1.0.0`. Never create a repo-wide `vX.Y.Z` tag.
- Create it with `git tag -a <bucket>@X.Y.Z` and push that tag. Do not use `claude plugin tag`:
  it only emits `<bucket>--vX.Y.Z`, which reads as a prerelease suffix rather than a scope.
- The version carries no `v` prefix. `<pkg>@<semver>` is the convention changesets, Lerna and Nx
  use for per-package releases in a monorepo, and it is what the plugin ecosystem reads.
- That command also checked manifest and marketplace agreement, so verify by hand before tagging:
  the bucket's `plugin.json` version must match the tag, and `marketplace.json` must carry an entry
  whose `source` points at that bucket. Marketplace entries hold no version of their own.
- Every tag is stable. This repo publishes no alphas, betas, or release candidates, so a version
  never carries a prerelease suffix.
- Bump `version` in the bucket's `plugin.json` through a PR before tagging — it must be on the
  tagged commit, and `main` takes no direct commits.
- Run `git fetch origin --tags` before picking a version; a stale local tag list produces a number
  that is already taken.
- The root `plugin.json` version tracks the skills.sh bundle and is not tagged.
- Superseded tags from earlier conventions (`<bucket>--vX.Y.Z`, `<bucket>/vX.Y.Z`) stay published
  as they are. The `@` form applies going forward.
