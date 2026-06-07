# Skrrt Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?logo=opensourceinitiative&logoColor=white)](LICENSE) [![Claude Code](https://img.shields.io/badge/Claude_Code-v1.0.33+-blueviolet?logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)

> Agent skills by skrrt-sh — git shipping workflows and documentation tools, installable with the
> [`skills`](https://skills.sh) CLI.

## Table of Contents

- [Installation](#installation)
- [Skills](#skills)
- [Requirements](#requirements)
- [Repository Structure](#repository-structure)
- [Contributing](#contributing)
- [License](#license)

## Installation

Install with the `skills` CLI and pick the skills and agents you want:

```bash
npx skills add skrrt-sh/skills
```

The CLI reads [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) and installs the listed
skills into your chosen coding agents.

To use every skill locally with the Claude CLI without the installer, symlink them into
`~/.claude/skills`:

```bash
./scripts/link-skills.sh
```

## Skills

Skills are grouped into buckets under [`skills/`](skills/).

### ship

Git shipping workflow — conventional commits, pull/merge requests, and releases with the matching
forge CLI. See the bucket index at [`skills/ship/`](skills/ship/README.md).

- **[commit](skills/ship/commit/SKILL.md)** — Conventional commits with gitmojis, split into focused changes.
- **[pr](skills/ship/pr/SKILL.md)** — Push branches and open GitHub PRs or GitLab MRs with the matching CLI.
- **[release](skills/ship/release/SKILL.md)** — Draft curated release notes and publish GitHub or GitLab releases.
- **[setup](skills/ship/setup/SKILL.md)** — Wire ship skills into `CLAUDE.md`/`AGENTS.md`; pick a branch strategy.

**Recommended first step — run `/setup`:** it wires directives into your project's `CLAUDE.md` (or
`AGENTS.md`) so Claude uses the ship skills automatically whenever it commits, opens a PR/MR, or
prepares a release, and configures a **branching strategy** (GitHub Flow, Trunk-Based Development,
or Gitflow) so all skills respect the correct target branches, merge rules, and release workflows.

```text
/setup wire skrrt skills into this project
/commit prepare a clean conventional commit for the auth refresh-token changes
/pr open a review request for the auth refresh-token branch
/release draft release notes for v1.4.0
```

**Recommended permissions:** Claude Code permissions live in `.claude/settings.json`, not in
`SKILL.md`. A recommended template ships at
[`templates/claude-settings.json`](templates/claude-settings.json) — merge it into your project's
`.claude/settings.json` for read-only git allowed automatically, mutating git/`gh`/`glab`
escalated with `permissions.ask`, force-push escalated to human approval, and destructive commands
such as `git reset --hard` denied.

### docs

Documentation authoring tools. See the bucket index at [`skills/docs/`](skills/docs/README.md).

- **[md-writer](skills/docs/md-writer/SKILL.md)** — Structured markdown: frontmatter, Mermaid diagrams, lint-clean.

```text
/md-writer API integration guide for the payments service
```

Or just ask Claude to write markdown — the skill activates automatically. As its final step it runs
the bundled validator (`skills/docs/md-writer/scripts/validate-md.sh`), which walks up from the file
for a project-level `.markdownlint.json` (`.jsonc`/`.yaml`/`.yml` also work) and falls back to the
skill's bundled default. Run `npm install` once inside the skill directory for a local
`markdownlint-cli2`, or the validator falls back to `npx`. It lints documentation and
knowledge-base content only — well-known repo files (`README`, `CLAUDE`, `CONTRIBUTING`, …) and
`.claude/` files are skipped.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) v1.0.33+
- Node.js 18+ (for the `npx skills` installer and the `md-writer` validator's `markdownlint-cli2`)

## Repository Structure

```text
.
├── .claude-plugin/
│   └── plugin.json                # Root manifest: { name, skills: [...] }
├── scripts/
│   ├── link-skills.sh             # Symlink every skill into ~/.claude/skills
│   └── list-skills.sh             # List all SKILL.md files
├── skills/
│   ├── ship/                      # Git shipping workflow bucket
│   │   ├── README.md
│   │   ├── commit/
│   │   │   ├── SKILL.md
│   │   │   ├── reference/{commit-types.md, gitmojis.md}
│   │   │   └── evals/{trigger-evals.json, commit-basic.json}
│   │   ├── pr/
│   │   │   ├── SKILL.md
│   │   │   ├── scripts/detect-forge-cli.sh
│   │   │   └── evals/{trigger-evals.json, pr-github.json}
│   │   ├── release/
│   │   │   ├── SKILL.md
│   │   │   ├── scripts/detect-forge-cli.sh
│   │   │   └── evals/{trigger-evals.json, release-changelog.json}
│   │   ├── setup/
│   │   │   ├── SKILL.md
│   │   │   ├── reference/branching-strategies.md
│   │   │   └── evals/trigger-evals.json
│   │   └── evals/evals.json       # Bucket-spanning ship suite
│   └── docs/                      # Documentation bucket
│       ├── README.md
│       └── md-writer/
│           ├── SKILL.md
│           ├── scripts/validate-md.sh
│           ├── config/markdownlint-default.json
│           ├── package.json
│           ├── package-lock.json
│           └── evals/evals.json
├── templates/
│   └── claude-settings.json       # Recommended Claude Code permissions
├── README.md
├── CLAUDE.md
├── LICENSE
├── skills-lock.json
└── .gitignore
```

## Contributing

### Dev Setup

Install the pinned development skills before working on the skills:

```bash
# Install dev skills (one-time, or after pulling new lock entries)
npx skills add anthropics/skills --skill skill-creator
```

This restores `.agents/` with the skill-creator used for eval workflows.

### Running Evals

Each skill keeps its eval fixtures co-located under its own `evals/` directory; the bucket-spanning
ship suite lives at `skills/ship/evals/evals.json`. Use the skill-creator to test changes:

```text
/skill-creator audit our skills, run evals
```

Eval workspaces (`md-writer-workspace/`, `ship-workspace/`) are gitignored — they are runtime
artifacts from running evals, not committed.

### Adding a Skill

1. Create `skills/<bucket>/<name>/SKILL.md` (plus any `reference/`, `scripts/`, `evals/`).
2. Add `"./skills/<bucket>/<name>"` to the `skills` array in `.claude-plugin/plugin.json`.
3. Add a linked entry to the bucket's `README.md` and to the [Skills](#skills) section above.

### Project Layout for Dev Files

```text
.agents/                  # Installed dev skills (gitignored, restored from lockfile)
skills-lock.json          # Lockfile for dev skills (committed)
md-writer-workspace/      # md-writer eval artifacts (gitignored)
ship-workspace/           # ship eval artifacts (gitignored)
```

## License

MIT
