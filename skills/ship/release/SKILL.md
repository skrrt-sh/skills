---
name: release
description: Draft, prepare, tag, or publish a GitHub or GitLab release. Use whenever the user asks for release notes or a release description, a summary of what changed for a version or since the last tag, or to prepare, tag, or publish a release. Not for deleting or moving existing tags.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh:*)
---

# Prepare a Release

Derive release facts from tags, commits, diffs, and repository configuration.

## Process

1. Classify the request before mutating anything:
   - **Notes only**: produce release text; do not edit files, tag, push, or publish.
   - **Prepare**: update requested local release files; do not tag, push, or publish.
   - **Publish**: perform the verified publication flow below.
2. Read `.agents/ship.md` at the repository root and validate the release branch and tag rules
   it defines. If it is missing in a repository that is not the user's own, such as open source
   or an org-wide repo, never run setup: follow its contributing rules, treat its default branch
   as protected, and ask for the tag format if those rules do not give one. Otherwise stop and
   ask the user to run `/setup`.
3. For Claude Code plugin repositories, read
   [references/claude-plugin-releases.md](references/claude-plugin-releases.md).
4. Run `git fetch origin --tags` so local tag data is current, then validate the requested tag
   format and confirm it does not exist locally or on the remote.
5. Find the previous release tag in the same namespace. Use `<previous>..HEAD` for an existing
   series. For an initial release, inspect the full history with `git log --reverse HEAD`; include
   the root commit and omit the compare link.
6. Draft reader-focused notes from commits and diffs. Update an existing `CHANGELOG.md` only for a
   prepare or publish request, preserving its style. Never create one unless asked.
7. For publication, stop if release preparation changed tracked files; those changes must reach the
   release branch through the configured commit and PR workflow first.
8. From the target repository, run
   `${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh`. Continue only on `STATUS=ok`.
9. Verify a clean worktree, `HEAD` at the required remote release commit, a non-empty release range,
   and the tag still absent remotely. Show the tag, commit, previous tag, and notes file, then
   publish only because the user requested publication.
10. Create and push an annotated tag. Create the release with that verified remote tag and the
    notes file (`gh release create --verify-tag` or `glab release create --no-update`). Read the
    release back, remove temporary files, and report its URL and tag.

## Release text

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
```

Omit empty sections. Keep internal changes only when they matter to users or operators. Never copy
a raw commit log or invent tests, changes, contributors, or links.

## Guardrails

- Publish only on an explicit publication request; loading this skill is not that request.
- Treat tags as immutable; fix a bad release with a new version.
- Never rebuild an artifact for promotion or move an existing tag.
- Never publish from uncommitted preparation changes or an unverified commit.
- Never force-push or delete a tag as part of this workflow.
- If forge publication fails after the tag is pushed, keep the tag and report a safe retry; do not
  retag another commit.
