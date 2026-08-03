---
name: pr
description: Creates or updates GitHub pull requests and GitLab merge requests with the matching CLI. Use when the agent needs to push a branch, open a review request, or write PR or MR text. Always use this skill when the user asks to open a PR, create a pull request, push and open a PR, create a merge request, update PR text, write a PR description, or anything involving pull requests or merge requests. Trigger for phrases like "open a PR", "create a pull request", "push and open a PR", "merge request", "MR on gitlab", "update the PR", or "write PR description".
argument-hint: "[pr-or-mr-goal]"
user-invocable: true
---

# Git PR Skill

Push a branch and open or update a review request with the forge's own CLI — `gh` for GitHub,
`glab` for GitLab. Never cross them.

## Workflow

1. **Branch guard** — run `git branch --show-current` and read the `<!-- skrrt:branching -->`
   block from `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`, or `.github/AGENTS.md` (first
   match). No block found → tell the user to run `/setup` and stop. Never push a PR from a
   protected branch; if the branch is wrong, branch off fresh `main` first.
2. **Detect the forge:**

   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/detect-forge-cli.sh"
   ```

   It prints `REMOTE_HOST`, `FORGE`, `MATCHED_CLI`, and `STATUS`. Continue only on `STATUS=ok`;
   otherwise stop and report exactly what is missing.
3. **Check for a precedent PR** if this is a follow-up (see below).
4. Push with `git push -u origin HEAD`, summarize the diff, then create or update the review
   request non-interactively with `--base` / `--target-branch` set to the strategy's target.

Target branch by strategy: **GitHub Flow / Trunk-Based** — always `main`; rebase onto `main`
first under GitHub Flow. **Gitflow** — feature branches target `develop`, never `main` (warn
if the user asks otherwise); `release/*` and `hotfix/*` target `main`, and after they merge
remind the user to open the sync-back PR to `develop` (or the active `release/*`). Never
rebase under Gitflow.

## Body

Use a review-friendly title naming the dominant change, not a copied commit subject.

```markdown
## Summary
- ...

## Test plan
- [ ] ...

## Related PRs
- **depends on** owner/repo#N — short description

## Notes
- ...
```

Omit `## Related PRs` when the PR is standalone. Report tests honestly — say none were run
rather than inventing results. End the body with
`Co-Authored-By: Skrrt Bot <bot@skrrt.sh>` unless the user says otherwise. Pass long bodies
via `--body-file <file>` (GitHub) or `--description` (GitLab).

## Correlated PRs

When one change spans several repos or independently deployable apps, every PR in the set lists
its siblings under `## Related PRs`, using `owner/repo#N` for GitHub and `group/project!N` for
GitLab:

- `depends on` — the linked PR must merge first.
- `required by` — the linked PR needs this one first.
- `related to` — no strict order. This is the default; never invent an order.

Keep references bidirectional: when a sibling is opened, update the open ones
(`gh pr edit <n> --repo <owner/repo> --body-file <file>`). Strike through entries as they merge.

## PR Follow-Up

If the user reports a problem inside a recent PR's scope, check that PR's state *before*
pushing — `gh pr view <n> --json state,headRefName,baseRefName` (or `glab mr view <n>`). If
they did not name it, match `gh pr list --state all --limit 10` candidates by keyword, changed
files, then recency; ask when two are plausible.

- **Open** — push to its source branch; the PR updates itself. Do not open a new one.
- **Merged** — the branch is gone. Switch to its base branch, `git fetch origin --prune`,
  `git pull --ff-only`, branch fresh, then open a new PR.
- **Closed unmerged** — ask the user before choosing.

Before pushing, confirm `git log origin/<branch>..HEAD` holds only the intended commits.

## Guardrails

- Never invent testing results.
- Never assume `origin` matches the installed CLI — trust the detector.
- Never use an interactive flow when a non-interactive command exists.
- Never force-push.
- Stop on `unknown-remote`, `no-remote`, or `no-compatible-cli`.

## Task

Handle this request: $ARGUMENTS
