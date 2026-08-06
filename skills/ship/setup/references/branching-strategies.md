# Branching strategy selection

Gather available evidence and recommend the lightest strategy that fits the repository.

| Signal | Inspect | Suggests |
| --- | --- | --- |
| Active `develop`, `release/*`, `hotfix/*` | Remote branches and recent merges | Gitflow only when release stabilization is real |
| CI on every change | GitHub/GitLab/Jenkins configuration | GitHub Flow; possibly Trunk-Based |
| Feature flags and frequent deployment | SDK/config and release cadence | Trunk-Based |
| Solo or small team | Distinct recent commit authors | GitHub Flow or Trunk-Based |
| Consumers track `main` | Plugin/library distribution | A continuously releasable `main` |
| Long stabilization phase | Fix-only commits between release cut and merge | Gitflow |
| Monorepo or independent services | Workspace files and per-package releases | Trunk-Based plus scoped release tooling |

Recommendation order:

1. Choose **GitHub Flow** for the lowest-overhead safe default.
2. Choose **Trunk-Based Development** when CI, feature flags, and frequent deployment support very
   short branches.
3. Choose **Gitflow** only when a dedicated stabilization branch solves an observed release need.

An existing `develop` branch is evidence to investigate, not a reason to preserve Gitflow. Old or
merged branches do not count as current practice. State uncertainty when repository evidence is
missing; do not fabricate team size or deployment cadence.

All strategies use immutable annotated tags, promote one built artifact, and reserve `vX.Y.Z` for
production. Pre-production tags use `vX.Y.Z-rc.N` or `vX.Y.Z-<environment>.N`.
