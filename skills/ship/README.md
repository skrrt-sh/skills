# ship

Git shipping workflow — conventional commits, pull/merge requests, and releases with the
matching forge CLI.

This bucket is its own Claude Code plugin — `claude plugin install ship@skrrt` — so its skills
are namespaced `/ship:commit`, `/ship:pr`, `/ship:release`, `/ship:setup`.

- **[commit](./commit/SKILL.md)** — Conventional commits with mandatory gitmojis, split into focused changes.
- **[pr](./pr/SKILL.md)** — Push branches and open GitHub PRs or GitLab MRs with the matching CLI.
- **[release](./release/SKILL.md)** — Draft curated release notes and publish GitHub or GitLab releases.
- **[setup](./setup/SKILL.md)** — Wire ship skills into `CLAUDE.md`/`AGENTS.md` and pick a branching strategy.
