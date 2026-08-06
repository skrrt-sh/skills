# Follow-up work

Before staging a fix to recent review work, identify the relevant PR or MR from a user-supplied
number or from matching keywords, changed files, and recency. Ask when more than one candidate is
plausible.

- **Open:** switch to its source branch, fast-forward it, and commit there.
- **Merged:** start a fresh branch from the configured work base. Never reuse the merged branch,
  even if the remote branch still exists.
- **Closed unmerged:** ask whether to revive its branch or start fresh.

Preserve the current worktree when switching would lose or overwrite changes. Never stash or move
work implicitly.
