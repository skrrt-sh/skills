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
