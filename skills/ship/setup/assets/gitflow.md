<!-- skrrt:strategy:gitflow -->
# Ship workflow — Gitflow

- Protected branches: `main` and `develop`.
- Feature work base and PR target: `develop`. Use `feat/<description>` branches.
- Releases: cut `release/<version>` from `develop` for fixes and version preparation only. Target
  `main`, then sync the merge back to `develop`.
- Hotfixes: cut `hotfix/<description>` from `main`. Target `main`, then sync to `develop` or the
  active release branch.
- Merge: preserve topology with non-fast-forward merges. Never rebase Gitflow branches.
- Production tags: immutable annotated `vX.Y.Z` tags on `main` release or hotfix merges.
- Pre-production tags: `vX.Y.Z-rc.N` on `release/*`. Pushes to `develop` may deploy to development
  without tags.
- Build once and promote the same artifact by content identity.
