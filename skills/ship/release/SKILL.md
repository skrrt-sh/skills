---
name: release
description: Drafts and publishes GitHub or GitLab releases with curated release notes. Use when the agent needs to prepare release text, compare tags, summarize release changes, or create a release. Always use this skill when the user asks to create a release, draft release notes, publish a release, summarize changes for a version, update a changelog for a release, or anything involving GitHub or GitLab releases. Trigger for phrases like "release notes", "draft a release", "publish release", "create a release", "v1.x.x release", "what changed since last tag", or "prepare release text".
argument-hint: "[release-goal]"
user-invocable: true
---

# Git Release Skill

Prepare release text and publish it with the forge's own CLI — `gh` for GitHub, `glab` for
GitLab. Use only when the user asks for a release, a draft, or release notes.

## Workflow

1. **Read the strategy** — find the `<!-- skrrt:branching -->` block in `CLAUDE.md`,
   `AGENTS.md`, `.claude/CLAUDE.md`, or `.github/AGENTS.md` (first match). No block found →
   tell the user to run `/setup` and stop.
2. **Detect the forge:**

   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh"
   ```

   Continue only when `FORGE` and `MATCHED_CLI` agree (`github`/`gh`, `gitlab`/`glab`);
   otherwise stop and report the mismatch.
3. **Validate the release context.** GitHub Flow / Trunk-Based: tag a commit on `main` — switch
   to `main` and pull first. Gitflow: the `release/*` (or `hotfix/*`) branch must already be
   merged to `main`; if not, stop and tell the user to open that PR with `/pr`. After tagging,
   remind them of the sync-back PR to `develop`.
4. `git fetch origin --tags`, then inspect tags and history for the release range
   (`git describe --tags --abbrev=0`,
   `git log --oneline <range>`). That command fails on a repo with no tags — treat that as the
   initial release: run the range from the root commit
   (`git log --oneline $(git rev-list --max-parents=0 HEAD)..HEAD`), say in the notes that no
   previous release tag was found, and omit the compare link.
5. Draft the notes, update an existing `CHANGELOG.md` if the repo has one, then publish.

## Tags

Annotated, on `main` only (Gitflow may carry `-rc.N` tags on `release/*`). Format:
`vX.Y.Z` for production, `vX.Y.Z-rc.N` for staging, `vX.Y.Z-<env>.N` for other tiers. Tags are
immutable — a bad release means a new patch version, never a moved tag.

**Always `git fetch origin --tags` before deriving a version.** `git tag --list` and
`git describe` read local refs, so a stale clone will report an old latest release and produce
a version that collides with a tag already published.

### Claude Code plugin repos

When `.claude-plugin/plugin.json` exists, bump its `version` to match the release *before*
tagging — it must be on the commit the tag points at, which under strategies that forbid
committing to `main` means it lands through a PR. After the `vX.Y.Z` tag, add the plugin tag:

```bash
claude plugin tag --push -m "%s"
```

That creates `<plugin-name>--vX.Y.Z` and refuses to run unless `plugin.json` and the enclosing
marketplace entry agree. It is a separate namespace from `vX.Y.Z`, not a competing format:
`vX.Y.Z` stays the release of record that CI globs and GitHub Releases key off, and the
name-prefixed tag is the marker Claude Code tooling reads. Run `--dry-run` first to see the tag
name and confirm validation passes.

**Repos shipping several plugins** — a `marketplace.json` whose entries point at subdirectories,
each with its own `plugin.json` — have no single repo version to put on `vX.Y.Z`. Drop it and let
`<plugin-name>--vX.Y.Z` be the release of record for each plugin, released on its own cadence.
Point the tag command at the plugin directory (`claude plugin tag --push ./path/to/plugin`), cut
one GitHub release per plugin tag, and derive each one's commit range from that plugin's own
previous tag, not the repo's:

```bash
git log --oneline "$(git tag --list '<name>--v*' | sort -V | tail -1)"..HEAD -- ./path/to/plugin
```

Renaming a plugin is breaking for everyone who installed it under the old name: bump the major,
and add a `renames` entry to `marketplace.json` mapping the old name to the new one so existing
installs migrate instead of orphaning.

## Release Text

```markdown
## What's Changed

### ✨ Features
- ...

### 🐛 Fixes
- ...

### ⚠️ Breaking Changes
- ...

### 🧰 Internal
- ...

**Full Changelog**: <compare link>

Co-Authored-By: Skrrt Bot <bot@skrrt.sh>
```

- Curate for readers; do not restate commit messages or paste a raw log.
- Omit empty sections. Breaking changes always get their own section.
- `docs`/`chore`/`ci`/`build`/refactors go under Internal only when readers care.
- Include testing only when it is actually known.

## Changelog

If `CHANGELOG.md` (any casing) exists, update it as part of the release and match its existing
style — Keep a Changelog or otherwise. Do not create one that does not exist unless asked.

## Guardrails

- Never publish when the user asked only for draft text.
- Never invent notes from guesswork — derive them from tags, commits, and diffs.
- Never force-push as part of a release.
- Stop on `unknown-remote`, `no-remote`, or `no-compatible-cli`.

## Task

Handle this request: $ARGUMENTS
