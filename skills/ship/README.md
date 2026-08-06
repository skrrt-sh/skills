# ship

Git shipping workflow — conventional commits, pull/merge requests, and releases with the
matching forge CLI.

This bucket is its own Claude Code plugin — `claude plugin install ship@skrrt` — so its skills
are namespaced `/ship:commit`, `/ship:pr`, `/ship:release`, `/ship:setup`.

Run it once per repository — `/ship:setup` on a plugin install, `/setup` on a skills.sh or
`~/.claude/skills` install. It is explicit-only, and it stores the selected policy in
`.agents/ship.md`, which the other three read before touching git state. Those three change
repository and forge state, so pair them with the permission rules in
`templates/claude-settings.json`.

- **[commit](./commit/SKILL.md)** — Conventional commits with mandatory gitmojis, split into focused changes.
- **[pr](./pr/SKILL.md)** — Push branches and open GitHub PRs or GitLab MRs with the matching CLI.
- **[release](./release/SKILL.md)** — Draft curated release notes and publish GitHub or GitLab releases.
- **[setup](./setup/SKILL.md)** — Add a short agent pointer and select a branching strategy.
