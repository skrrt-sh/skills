# Skrrt Skills

[![skills.sh](https://skills.sh/b/skrrt-sh/skills)](https://skills.sh/skrrt-sh/skills) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?logo=opensourceinitiative&logoColor=white)](LICENSE) [![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-blueviolet?logo=anthropic&logoColor=white)](https://code.claude.com/docs/en/plugins)

> Agent skills by skrrt-sh — ship your git work properly. Conventional commits, pull and merge
> requests, releases, and the markdown that documents them.

## Table of Contents

- [Installation](#installation)
- [Skills](#skills)
- [Requirements](#requirements)
- [Repository Structure](#repository-structure)
- [Contributing](#contributing)
- [License](#license)

## Installation

Two ways in, two philosophies. **The [Claude Code plugin](https://code.claude.com/docs/en/plugins)**
installs the whole set as a managed, read-only bundle that updates when we ship — you subscribe
rather than fork. **[skills.sh](https://skills.sh)** puts editable skill files in your project, so
you can hack on them and make them your own. Pick one — installing both leaves you with every
skill twice.

### 1. Get the skills

<details>
<summary><strong>Claude Code</strong></summary>

```bash
claude plugin marketplace add skrrt-sh/skills
claude plugin install skrrt-skills@skrrt
```

Or, from inside a session:

```text
/plugin marketplace add skrrt-sh/skills
/plugin install skrrt-skills@skrrt
```

These skills are not in Claude Code's official marketplace, so the `marketplace add` step is
required once — after that, `claude plugin update skrrt-skills` pulls new versions.

</details>

<details>
<summary><strong>Codex, and other agents</strong></summary>

```bash
npx skills add skrrt-sh/skills
```

Pick the skills you want, and which coding agents to install them on. **The installer lets you
choose which skills to take — make sure `setup` is one of them.**

</details>

<details>
<summary><strong>For tinkerers</strong></summary>

Use the same installer, on any agent — including Claude Code:

```bash
npx skills add skrrt-sh/skills
```

It writes the skills into your repo as ordinary files you own and can edit — by default a
canonical copy under `.agents/skills/`, symlinked into each agent's directory, so one edit
reaches every agent. Pass `--copy` for independent per-agent copies instead, which you need on
filesystems without symlink support. Nothing updates behind your back; pull the latest changes
when you want them with `npx skills update`.

Working on the skills themselves? Symlink every one of them into `~/.claude/skills` instead:

```bash
./scripts/link-skills.sh
```

</details>

### 2. Run the setup skill

In your agent, run it once per repo — `/skrrt-skills:setup` on a plugin install, `/setup` on a
skills.sh install (see the note on skill names below). It will:

- Detect your agent instruction file (`CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`, or
  `.github/AGENTS.md`) and add the ship workflow block
- Analyze the repo — CI, feature flags, contributor count, deploy cadence, existing branches —
  and recommend a **branching strategy** (GitHub Flow, Trunk-Based Development, or Gitflow),
  with all three presented so you make the final call
- Write the chosen strategy's rules so the commit, pr, and release skills respect the right
  target branches, merge rules, and tagging conventions

### 3. Bam — you're ready to go

```text
/skrrt-skills:commit prepare a clean conventional commit for the auth refresh-token changes
/skrrt-skills:pr open a review request for the auth refresh-token branch
/skrrt-skills:release draft release notes for v1.4.0
```

**Skill names depend on how you installed.** Claude Code namespaces plugin skills by plugin
name, so a plugin install gives you `/skrrt-skills:commit`, `/skrrt-skills:pr`,
`/skrrt-skills:release`, `/skrrt-skills:setup`, and `/skrrt-skills:md-writer`. A skills.sh or
`~/.claude/skills` install uses the bare names — `/commit`, `/pr`, `/release`, `/setup`,
`/md-writer`. The rest of this README uses the bare names for brevity.

## Skills

Skills are grouped into buckets under [`skills/`](skills/). Every one is user-invocable by name;
the model also reaches for them on its own when the task fits.

### ship

Git shipping workflow — conventional commits, pull/merge requests, and releases with the matching
forge CLI. Bucket index: [`skills/ship/`](skills/ship/README.md).

- **[setup](skills/ship/setup/SKILL.md)** — Wire the ship skills into `CLAUDE.md`/`AGENTS.md` and
  pick a branching strategy. Run once per repo, before the rest.
- **[commit](skills/ship/commit/SKILL.md)** — Split the worktree into focused conventional commits
  with a mandatory gitmoji, guarding against commits on a protected branch.
- **[pr](skills/ship/pr/SKILL.md)** — Push the branch and open a GitHub PR or GitLab MR with the
  forge's own CLI, targeting the branch your strategy dictates.
- **[release](skills/ship/release/SKILL.md)** — Draft curated release notes from the commit range,
  update an existing changelog, and publish the release.

**Recommended permissions:** these skills set no `allowed-tools` of their own, so the project's
shared allow/ask/deny rules in `.claude/settings.json` govern them. A template ships at
[`templates/claude-settings.json`](templates/claude-settings.json)
— merge it into your project's `.claude/settings.json` for read-only git allowed automatically,
mutating git/`gh`/`glab` escalated with `permissions.ask`, force-push escalated to human approval,
and destructive commands such as `git reset --hard` denied.

### docs

Documentation authoring tools. Bucket index: [`skills/docs/`](skills/docs/README.md).

- **[md-writer](skills/docs/md-writer/SKILL.md)** — Knowledge-base markdown with YAML frontmatter,
  Mermaid diagrams, bidirectional cross-links, and a lint-clean finish.

```text
/md-writer API integration guide for the payments service
```

Or just ask for markdown — the skill activates on its own. As its final step it runs the bundled
validator (`skills/docs/md-writer/scripts/validate-md.sh`), which walks up from the file for a
project-level `.markdownlint.json` (`.jsonc`/`.yaml`/`.yml` also work) and falls back to the
skill's bundled default. Run `npm install` once inside the skill directory for a local
`markdownlint-cli2`, or it falls back to `npx`. It lints documentation and knowledge-base content
only — well-known repo files (`README`, `CLAUDE`, `CONTRIBUTING`, …) and `.claude/` files are
skipped.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — any version with plugin
  marketplace support (`claude plugin marketplace`) for the plugin install; v1.0.33+ otherwise
- `gh` for GitHub remotes, `glab` for GitLab remotes (used by `/pr` and `/release`)
- Node.js 18+ (for the `npx skills` installer and the `md-writer` validator's `markdownlint-cli2`)

## Repository Structure

```text
.
├── .claude-plugin/
│   ├── marketplace.json           # Claude Code marketplace entry: { name, plugins: [...] }
│   └── plugin.json                # Plugin manifest: { name, version, skills: [...] }
├── scripts/
│   ├── link-skills.sh             # Symlink every skill into ~/.claude/skills
│   └── list-skills.sh             # List all SKILL.md files
├── skills/
│   ├── ship/                      # Git shipping workflow bucket
│   │   ├── README.md
│   │   ├── commit/
│   │   │   ├── SKILL.md
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

`.claude-plugin/marketplace.json` needs no edit — it points at the repo root, so the plugin
ships whatever `plugin.json` declares. When cutting a release tag, bump `version` in
`.claude-plugin/plugin.json`, which is where Claude Code reads the plugin version.

### Project Layout for Dev Files

```text
.agents/                  # Installed dev skills (gitignored, restored from lockfile)
skills-lock.json          # Lockfile for dev skills (committed)
md-writer-workspace/      # md-writer eval artifacts (gitignored)
ship-workspace/           # ship eval artifacts (gitignored)
```

## License

MIT
