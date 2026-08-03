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
4. Inspect tags and history for the release range (`git describe --tags --abbrev=0`,
   `git log --oneline <range>`). That command fails on a repo with no tags — treat that as the
   initial release: run the range from the root commit
   (`git log --oneline $(git rev-list --max-parents=0 HEAD)..HEAD`), say in the notes that no
   previous release tag was found, and omit the compare link.
5. Draft the notes, update an existing `CHANGELOG.md` if the repo has one, then publish.

## Tags

Annotated, on `main` only (Gitflow may carry `-rc.N` tags on `release/*`). Format:
`vX.Y.Z` for production, `vX.Y.Z-rc.N` for staging, `vX.Y.Z-<env>.N` for other tiers. Tags are
immutable — a bad release means a new patch version, never a moved tag.

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
