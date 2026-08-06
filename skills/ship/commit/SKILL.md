---
name: commit
description: Create focused conventional commits with a mandatory gitmoji. Use when the user asks to commit, write a commit message, or split changes into commits.
---

# Commit Changes

Create the smallest coherent commits that explain what changed and why.

## Format

```text
type(scope): :gitmoji: imperative subject

body explaining what changed and why

footer
```

- Use a standard conventional-commit type and [gitmoji](https://gitmoji.dev) code.
- Put the gitmoji immediately after `type(scope):`; omit an uncertain scope.
- Include a body for every commit.
- Add `BREAKING CHANGE:` only for a real breaking change.
- Add issue footers only for issues the user or repository identifies.
- End with `Co-Authored-By: Skrrt Bot <bot@skrrt.sh>` unless the user opts out.

## Process

1. Read `.agents/ship.md` at the repository root. If missing, stop and ask the user to run
   `/setup`.
2. Inspect `git status --short`, staged and unstaged diffs, and the current branch. Do not include
   unrelated files without approval.
3. Protect work on a forbidden branch before staging: create a correctly named work branch from
   the current `HEAD` with `git switch -c <type>/<description>`. Do not pull, switch bases, or stash
   first; the new branch must retain the current worktree exactly.
4. If this is a fix to a recent PR or MR, read
   [references/follow-up.md](references/follow-up.md) before staging.
5. Group the diff by intent. If a type and gitmoji disagree, split the change instead of forcing a
   message.
6. Stage only the intended files or hunks. Review `git diff --cached` before each commit.
7. Write the message to a `mktemp` file outside the repository, commit with
   `git commit --file <file>`, then remove it. A fixed path is unsafe: a second agent, or your own
   next commit, can overwrite the message between writing it and committing, which silently ships a
   message describing the wrong diff.
8. Verify the resulting commit and report its hash, subject, included files, and known test status.

## Guardrails

- Commit only when the user asked for a commit; loading this skill is not that request.
- Follow the protected branches and work base in `.agents/ship.md`.
- Preserve unrelated and untracked work.
- Never invent test results, amend, rewrite history, or force-push unless explicitly requested.
- Never commit secrets or likely credential files; stop and warn the user.
