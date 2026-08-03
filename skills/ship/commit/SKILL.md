---
name: commit
description: Creates focused conventional commits with mandatory gitmojis. Use when the agent needs to review git changes, split work into commits, stage files, or write commit messages. Always use this skill when the user asks to commit, make a commit, write a commit message, split changes into commits, stage and commit files, or anything involving git commit workflows. Trigger for phrases like "commit this", "write a commit", "split into commits", "conventional commit", "gitmoji commit", "stage and commit", "commit the changes", or "help me commit".
argument-hint: "[what-to-commit]"
user-invocable: true
---

# Git Commit Skill

Split changes into focused conventional commits with a mandatory gitmoji.

## Commit Format

```text
type(scope): :gitmoji: imperative subject

body explaining what changed and why

footer
```

- Gitmoji is mandatory, in code form (`:sparkles:`), placed immediately after `type(scope):`.
  Never before the type, never at the end of the subject. Use the standard
  [gitmoji](https://gitmoji.dev) catalog and conventional-commit types.
- Scope is optional; drop it rather than inventing one.
- The body is required for every commit this skill writes.
- Footer: `BREAKING CHANGE:` for breaking changes. Add `Closes #N` / `Refs #N` only when the
  user names an issue — never invent one.
- Always end with `Co-Authored-By: Skrrt Bot <bot@skrrt.sh>` unless the user says otherwise.

## Workflow

1. Run the branch guard below.
2. Inspect the worktree (`git status --short`, `git diff`).
3. Group the diff into the smallest coherent change sets — never mix unrelated intents.
4. Stage only the intended files or hunks, then commit with `git commit --file <file>`.

If type and gitmoji pull in different directions, the split is wrong — fix the split, not the
message.

## Branch Guard

Before staging anything, run `git branch --show-current` and read the `<!-- skrrt:branching -->`
block from `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`, or `.github/AGENTS.md` (first match).
No block found → tell the user to run `/setup` and stop.

Never commit to a protected branch (`main`, `master`, and `develop` under Gitflow, where only
release preparation is allowed). If the branch is wrong, fix it before staging — branching from
the base the strategy dictates, which is `main` under GitHub Flow and Trunk-Based but `develop`
for Gitflow feature work (Gitflow hotfixes branch from `main`):

```bash
git fetch origin
git switch <base> && git pull --ff-only origin <base>
git switch -c <type>/<description>
```

Never stage on the wrong branch planning to move the work later.

## PR Follow-Up

If the change fixes recent work, check the precedent PR's state *before* staging —
`gh pr view <n> --json state,headRefName,baseRefName` (or `glab mr view <n>`). If the user did
not name it, match `gh pr list --state all --limit 10` candidates by keyword, changed files,
then recency; ask when two are plausible.

- **Open** — switch to its source branch, `git pull --ff-only`, commit there.
- **Merged** — the branch is gone. Switch to its base branch, `git fetch origin --prune`,
  `git pull --ff-only`, then branch fresh. Never reuse a merged branch.
- **Closed unmerged** — ask the user before choosing.

## Guardrails

- Never commit unrelated files; ask before including anything that looks out of scope.
- Never invent testing results.
- Never amend, rewrite history, or force-push unless explicitly asked.
- Rebase commands are allowed only under GitHub Flow and Trunk-Based, never under Gitflow.

## Task

Handle this request: $ARGUMENTS
