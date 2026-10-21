---
name: pr
description: Push a branch, open or update its GitHub pull request or GitLab merge request, and merge it when asked. Use when the user asks to open, update, or merge a PR or merge request.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh:*)
---

# Open a Review Request

Use the forge that owns the remote: `gh` for GitHub, `glab` for GitLab.

## Process

1. Read `.agents/ship.md` at the repository root and derive the protected branches and target
   branch from it. If it is missing in a repository that is not the user's own, such as open
   source or an org-wide repo, never run setup: follow its contributing rules, target and protect
   its default branch, and ask before merging if those rules do not say how. Otherwise stop and
   ask the user to run `/setup`.
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
   A published branch behind its target gets `git merge origin/<target>`, never a rebase.
   Under Gitflow, never rebase. Feature branches target `develop`; `release/*` and `hotfix/*`
   target `main`.
6. If this work follows a recent PR or MR, read
   [references/follow-up.md](references/follow-up.md). If it spans repositories or independently
   deployed applications, also read [references/correlated-prs.md](references/correlated-prs.md).
7. Run the project's full CI suite locally; never push red. Confirm the outgoing commit range
   contains only intended commits. Push with
   `git push -u origin HEAD` unless step 5 received explicit rewrite approval.
8. Create or update the review request non-interactively with an explicit target branch.
9. Wait for the checks and review bots. For a failure, read its log first and state with evidence
   whether your change caused it. Fix your failures and address every review comment, then
   report the URL, source, target, and each check's final state.

## Merge

Only when the user asks to merge. Do every step yourself; never hand the merge back.

1. Wait for the required checks. Without CI, run the full build, tests, and lint locally. Never
   merge on a failure; report it with its output.
2. Merge with the strategy in `.agents/ship.md`: `gh pr merge` or `glab mr merge`.
3. Switch to the target branch, then fetch and pull. If the target is checked out in another
   worktree, move there instead.
4. Remove the merged branch's worktree, if one exists, then delete the merged local branch.
5. If the target branch deploys, wait for the deploy and confirm the change is live.
6. Report the merged request's number and URL, and the live URL if one exists.

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
- Push with the forge account named in `.agents/ship.md`, if one is named.
- Fetch before comparing branches or reporting how they relate; never reason from a stale ref.
- Never use plain `--force`; only `--force-with-lease` after explicit approval.
- Never open a duplicate request when the current branch already has one.
- Never move a branch to change only a request's text; update the request in place.
- Merge only when the user asks; opening a request is not that ask.
