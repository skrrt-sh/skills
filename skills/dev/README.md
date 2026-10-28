# dev

Implementation workflow tools.

This bucket is its own Claude Code plugin (`claude plugin install dev@skrrt`), so its skills are
namespaced `/dev:<name>`.

- **[subagents](./subagents/SKILL.md)**: The main thread plans, briefs, and reviews. Strictly scoped subagents write the code.
- **[herdr-agents](./herdr-agents/SKILL.md)**: Inside Herdr, run each scope as a named agent in its own git worktree, then integrate the diffs and delete the worktrees.
- **[design-principles](./design-principles/SKILL.md)**: DRY, loose coupling, separation of concerns, minimal diffs. Every change deletes the code it replaces.
- **[testing](./testing/SKILL.md)**: Test only business logic and its corner cases. Delete tests for removed or replaced behavior.
- **[research](./research/SKILL.md)**: Decide from current docs, peer projects, and claims verified against the code.
- **[reporting](./reporting/SKILL.md)**: Plain, concrete reports. No mid-run questions; open questions as one numbered list with recommendations at the end.
- **[self-documenting](./self-documenting/SKILL.md)**: The code is the single source of truth. Docs are only the README, architecture, decisions, and a transient plan. AGENTS.md is the only instruction file, and every change fixes or deletes the prose it makes false.

Each concern has exactly one skill. `subagents` puts `design-principles`, `testing`,
`self-documenting`, and `research` into every brief and holds every review to them.
