<p align="center">
  <img src="https://raw.githubusercontent.com/skrrt-sh/skills/main/assets/banner.png" alt="Skills" width="480">
</p>

<h1 align="center">Skrrt Skills</h1>

<p align="center">
  Agent skills by skrrt-sh — ship your git work properly. Conventional commits,<br>
  pull and merge requests, releases, and the markdown that documents them.
</p>

<p align="center">
  <a href="https://skills.sh/skrrt-sh/skills"><img src="https://skills.sh/b/skrrt-sh/skills" alt="skills.sh"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?logo=opensourceinitiative&logoColor=white" alt="License: MIT"></a>
  <a href="https://code.claude.com/docs/en/plugins"><img src="https://img.shields.io/badge/Claude_Code-plugin-blueviolet?logo=anthropic&logoColor=white" alt="Claude Code plugin"></a>
</p>

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
claude plugin install ship@skrrt
claude plugin install docs@skrrt
claude plugin install dev@skrrt
```

Or, from inside a session:

```text
/plugin marketplace add skrrt-sh/skills
/plugin install ship@skrrt
/plugin install docs@skrrt
/plugin install dev@skrrt
```

Each bucket is its own plugin, versioned and released independently — install only the ones you
want. These skills are not in Claude Code's official marketplace, so the `marketplace add` step is
required once; after that, `claude plugin update ship` pulls new versions.

> **Upgrading from the single `skrrt` plugin?** It was split into `ship` and `docs` so the slash
> namespace names the bucket — `/skrrt:commit` is now `/ship:commit`. The marketplace declares the
> `skrrt` → `ship` rename, so an updated marketplace migrates your install automatically; if skills
> go missing afterwards, `claude plugin install ship@skrrt` repairs it. `docs` is new either way —
> install it explicitly.

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

In your agent, run it once per repo — `/ship:setup` on a plugin install, `/setup` on a
skills.sh install (see the note on skill names below). It will:

- Add a short, marker-delimited pointer to your existing instruction file — the first of
  `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`, or `.github/AGENTS.md` that exists
- Analyze the repo — CI, feature flags, contributor count, deploy cadence, existing branches —
  and recommend a **branching strategy** (GitHub Flow, Trunk-Based Development, or Gitflow),
  with all three presented so you make the final call
- Write only the chosen strategy to `.agents/ship.md`, loaded by the ship skills when needed

### 3. Bam — you're ready to go

```text
/ship:commit prepare a clean conventional commit for the auth refresh-token changes
/ship:pr open a review request for the auth refresh-token branch
/ship:release draft release notes for v1.4.0
```

**Skill names depend on how you installed.** Claude Code namespaces plugin skills by plugin
name, and each bucket is its own plugin — so a plugin install gives you `/ship:commit`, `/ship:pr`,
`/ship:release`, `/ship:setup`, `/docs:md-writer`, and `/dev:subagents`. A skills.sh or
`~/.claude/skills` install uses the bare names — `/commit`, `/pr`, `/release`, `/setup`,
`/md-writer`, `/subagents`. The rest of this README uses the bare names for brevity.

## Skills

Skills are grouped into buckets under [`skills/`](skills/). Every one is user-invocable by name, and
all but `setup` also activate on their own when the task fits — that is the point: a hidden skill
just means the agent runs raw `git commit` instead. Side effects are gated where they happen, by the
permission rules in [`templates/claude-settings.json`](templates/claude-settings.json), which put
`git commit`, `git push`, and the forge create commands behind an approval prompt. `setup` is a
run-once configurator, so it stays explicit-only.

### ship

Git shipping workflow — conventional commits, pull/merge requests, and releases with the matching
forge CLI. Bucket index: [`skills/ship/`](skills/ship/README.md).

- **[setup](skills/ship/setup/SKILL.md)** — Add the ship policy pointer and pick a branching
  strategy. Run once per repo, before the rest.
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
  Mermaid diagrams, related-document links, and a lint-clean finish.

```text
/md-writer API integration guide for the payments service
```

Or ask for a guide, spec, ADR, runbook, or API document — the skill activates on its own. Repository
meta files such as README, CHANGELOG, CLAUDE.md, AGENTS.md, and SKILL.md are deliberately excluded.
As its final step it runs the bundled validator (`skills/docs/md-writer/scripts/validate-md.sh`),
which walks up from the file for a
project-level `.markdownlint.json` (`.jsonc`/`.yaml`/`.yml` also work) and falls back to the
skill's bundled default. It prefers a pinned local `markdownlint-cli2`, then the exact pinned
version through `npx`. The validator auto-fixes mechanical rules in place and reports only what
needs judgment
— line length, fence languages, headings, links — so the agent spends tokens on those alone. It
lints documentation and knowledge-base content only — well-known repo files (`README`, `CLAUDE`,
`CONTRIBUTING`, …) and `.claude/` files are skipped and never rewritten. Missing tooling is an
explicit failure, never a false validation pass.

### dev

Implementation workflow tools. Bucket index: [`skills/dev/`](skills/dev/README.md).

- **[subagents](skills/dev/subagents/SKILL.md)** — Orchestrate strictly scoped subagents from a
  main thread that only plans and reviews.

```text
/subagents implement the outlined scope — orchestrate and review, delegate the code
```

The main thread stays on Fable or Opus and holds the judgement — it assesses the system, decides the
path, briefs, dispatches, reviews, and pivots when the evidence says to. Subagents
run on Opus unless you say otherwise, get briefs naming the files they own and the files off limits,
and leave git alone. Every file belongs to exactly one scope; contracts land in a stage before the
code that consumes them. At most five subagents run at once — a scope with more parts becomes
sequential stages, and each stage is reviewed against the real diff, not the subagents' own
summaries, before the next one starts.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — any version with plugin
  marketplace support (`claude plugin marketplace`) for the plugin install; v1.0.33+ otherwise
- `gh` for GitHub remotes, `glab` for GitLab remotes (used by `/pr` and `/release`)
- Node.js 22.20+ — the `npx skills` installer declares `>=22.20.0`, and the `md-writer`
  validator's `markdownlint-cli2` requires `>=22` as of 0.23

## Repository Structure

```text
.
├── .claude-plugin/                # Marketplace and aggregate manifests
├── .github/workflows/validate.yml # Public CI validation
├── .agents/ship.md                # This repo's selected ship policy
├── scripts/
│   ├── list-skills.sh             # List every discovered skill
│   ├── link-skills.sh             # Local development links
│   ├── validate-skills.sh         # Structure, links, budgets, and eval schemas
│   ├── test-*.sh                  # Setup, forge detector, validator, installed paths
│   └── test-skills.sh             # Complete deterministic test suite
├── skills/
│   ├── ship/                      # setup, commit, pr, release
│   ├── docs/md-writer/
│   └── dev/subagents/
└── templates/claude-settings.json # Recommended Claude permissions
```

Within a skill: `SKILL.md`, `references/`, `scripts/`, `assets/`, `config/`, `agents/openai.yaml`,
`evals/`.

Each skill keeps only its core workflow in `SKILL.md`. Conditional knowledge lives one level deep
under `references/`; deterministic operations live under `scripts/`; output templates live under
`assets/`; behavior eval manifests live under `evals/`; Codex UI policy lives in
`agents/openai.yaml`.

## Contributing

### Dev Setup

Install the pinned development skills before working on the skills:

```bash
# Install dev skills (one-time, or after pulling new lock entries)
npx skills add anthropics/skills --skill skill-creator
```

This restores `.agents/` with the skill-creator used for eval workflows.

### Running Evals

Each skill keeps at least three Agent Skills-compatible behavior cases under `evals/evals.json`.
These manifests define prompts, expected outputs, and gradeable assertions; they are not test
results. Every model-invocable skill also carries at least 20 balanced trigger queries in
`evals/trigger-evals.json`, half of which must be requests it should decline — usually a
neighbouring skill's territory. `setup` is exempt because it is explicit-only. The ship bucket
additionally has a repository-specific integration scenario suite.

Run deterministic schema, script, path-resolution, and lint checks locally exactly as CI does:

```bash
npm ci --prefix skills/docs/md-writer
./scripts/test-skills.sh
```

The behavior prompts describe repository states rather than shipping files, so build the fixtures
first and grade against real repository state afterwards:

```bash
./scripts/build-eval-fixtures.sh /tmp/skrrt-eval-fixtures   # one git repo per scenario
python3 scripts/grade-eval-runs.py <workspace>/iteration-N  # writes grading.json per run
```

`grade-eval-runs.py` decides the objective assertions and leaves process assertions (\"the staged
diff was reviewed\") as `passed: null` for a human or grading agent. Snapshot a baseline skill with
`rsync -a`, never `cp -r` — plain `cp -r` breaks the `node_modules/.bin` symlinks and the baseline
then fails on tooling rather than on behavior.

Use the skill-creator to run each behavior case in a fresh context both with the skill and against a
baseline, then save outputs, grading evidence, timing, and the aggregate benchmark in the gitignored
workspace:

```text
/skill-creator audit our skills, run evals
```

Eval workspaces (`md-writer-workspace/`, `ship-workspace/`) are gitignored — they are runtime
artifacts from running evals, not committed.

### Adding a Skill

1. Create `skills/<bucket>/<name>/SKILL.md` and only the needed `references/`, `scripts/`,
   `assets/`, and `evals/` resources. Generate `agents/openai.yaml`.
2. Add `"./<name>"` to the `skills` array in `skills/<bucket>/.claude-plugin/plugin.json` — the
   bucket's own plugin manifest, and where Claude Code reads it from.
3. Add `"./skills/<bucket>/<name>"` to the `skills` array in the root `.claude-plugin/plugin.json`,
   the repo-wide aggregate (the skills.sh CLI discovers skills by scanning for `SKILL.md`, but the
   aggregate is the declared inventory).
4. Add a linked entry to the bucket's `README.md` and to the [Skills](#skills) section above.

`.claude-plugin/marketplace.json` needs no edit for a new skill — it lists buckets, not skills.
A **new bucket** does need one: create `skills/<bucket>/.claude-plugin/plugin.json` and add a
matching entry pointing `"source"` at `./skills/<bucket>`. Each bucket carries its own `version`
and releases on its own cadence.

### Project Layout for Dev Files

```text
.agents/skills/           # Installed dev skills (gitignored, restored from lockfile)
.agents/ship.md           # This repo's ship policy (committed)
skills-lock.json          # Lockfile for dev skills (committed)
md-writer-workspace/      # md-writer eval artifacts (gitignored)
ship-workspace/           # ship eval artifacts (gitignored)
```

## License

MIT
