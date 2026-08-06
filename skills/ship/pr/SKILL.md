---
name: pr
description: Push a branch and open or update its GitHub pull request or GitLab merge request. Use when the user asks to open a PR, or to create or update a merge request.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh:*)
---

# Open a Review Request

Use the forge that owns the remote: `gh` for GitHub, `glab` for GitLab.

## Process

1. Read `.agents/ship.md` at the repository root. If missing, stop and ask the user to run
   `/setup`. Derive the protected branches and target branch from this file.
2. Confirm the current branch is not protected.
3. From the target repository, run
   `${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh`. Continue only when it prints
   `STATUS=ok`; otherwise report its status and stop.
4. Look up any open request for the current branch. If one exists and the user asked only to
   revise its title or body, go straight to step 8 — a metadata-only edit must not fetch, rebase,
   or push, and it keeps the request's existing source and target branches.
5. Confirm the worktree has no uncommitted changes that should be part of the review, then fetch
   the target branch. Under GitHub Flow or Trunk-Based Development:
   - If `origin/<current-branch>` does not exist, rebase onto `origin/main` when needed.
   - If the published branch needs a history rewrite, stop and ask before rebasing and pushing with
     `--force-with-lease`.
   Under Gitflow, never rebase. Feature branches target `develop`; `release/*` and `hotfix/*`
   target `main`.
6. If this work follows a recent PR or MR, read
   [references/follow-up.md](references/follow-up.md). If it spans repositories or independently
   deployed applications, also read [references/correlated-prs.md](references/correlated-prs.md).
7. Confirm the outgoing commit range contains only intended commits. Push with
   `git push -u origin HEAD` unless step 5 received explicit rewrite approval.
8. Create or update the review request non-interactively with an explicit target branch.
9. Read the request back from the forge and report its URL, source, target, and test status.

## Body

Use a review-focused title and this compact structure:

```markdown
## Summary
- ...

## Test plan
- [ ] ...

## Notes
- ...
```

Omit empty optional sections. Report unrun tests honestly. End with
`Co-Authored-By: Skrrt Bot <bot@skrrt.sh>` unless the user opts out. Use a temporary body file for
multi-line content.

## Guardrails

- Push and open a request only when the user asked for one; loading this skill is not that request.
- Trust the detector, not an assumed `origin` host.
- Never use plain `--force`; only `--force-with-lease` after explicit approval.
- Never open a duplicate request when the current branch already has one.
- Never move a branch to change only a request's text; update the request in place.
- Never merge the request unless the user separately asks.
