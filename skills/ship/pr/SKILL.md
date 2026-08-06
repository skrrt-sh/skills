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
2. Confirm the current branch is not protected and the worktree has no uncommitted changes that
   should be part of the review.
3. From the target repository, run
   `${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh`. Continue only when it prints
   `STATUS=ok`; otherwise report its status and stop.
4. Fetch the target branch. Under GitHub Flow or Trunk-Based Development:
   - If `origin/<current-branch>` does not exist, rebase onto `origin/main` when needed.
   - If the published branch needs a history rewrite, stop and ask before rebasing and pushing with
     `--force-with-lease`.
   Under Gitflow, never rebase. Feature branches target `develop`; `release/*` and `hotfix/*`
   target `main`.
5. If this work follows a recent PR or MR, read
   [references/follow-up.md](references/follow-up.md). If it spans repositories or independently
   deployed applications, also read [references/correlated-prs.md](references/correlated-prs.md).
6. Confirm the outgoing commit range contains only intended commits. Push with
   `git push -u origin HEAD` unless step 4 received explicit rewrite approval.
7. Create or update the review request non-interactively with an explicit target branch.
8. Read the created request back from the forge and report its URL, source, target, and test status.

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
- Never merge the request unless the user separately asks.
