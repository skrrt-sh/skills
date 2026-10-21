---
name: herdr-agents
description: Dispatch subagent scopes as real coding agents in Herdr. One git worktree, one workspace, and one named agent per scope. Exchange mail with them, integrate their diffs, and delete the worktrees. Use when running inside Herdr (HERDR_ENV=1) and the user wants agents in worktrees, Herdr panes, or parallel work on separate checkouts, or wants to message or clean up those agents. Not for installing Herdr or operating a single pane. The subagents skill still owns planning, briefs, and review.
---

# Herdr Agents

The `subagents` skill decides the scopes. This skill runs each scope in its own checkout.

Guard: `test "${HERDR_ENV:-}" = 1`. If it fails, say so and dispatch with the `Agent` tool.
Read-only `Explore` work always uses the `Agent` tool.

## Mail

The bundled `herdr-mail` plugin holds mail until the recipient is idle. Its hooks mail each
child's `done`, `blocked`, and `exited` states to the parent. Check it once per run:

```bash
mail="${CLAUDE_SKILL_DIR}/assets/herdr-mail/bin/herdr-mail"
herdr plugin list --json | jq -e --arg r "${CLAUDE_SKILL_DIR}/assets/herdr-mail" \
  '.result.plugins[] | select(.plugin_id == "skrrt.herdr-mail" and .plugin_root == $r)'
```

No match: ask the user, then run `herdr plugin link "${CLAUDE_SKILL_DIR}/assets/herdr-mail"`. It
runs in every Herdr session. Suggest allowing `Bash(<$mail path>:*)`, or each child stops on a
permission prompt at its first send.

## Dispatch

Once per run, confirm `herdr worktree create`, `herdr agent start`, and `$mail` are allowed. If
not, ask the user once for the rules, not per agent.

Once per stage, snapshot the base: `base=$(git stash create)`, or `HEAD` on a clean tree. It
captures the integrated earlier stages without committing or signing.

Per scope. Name the agent after the scope, matching `[a-z][a-z0-9_-]{0,31}`. Read every ID from
JSON.

```bash
ws=$(herdr worktree create --cwd "$PWD" --branch "scope/$name" --base "${base:-HEAD}" --label "$name" --no-focus)
pane=$(jq -r .result.root_pane.pane_id <<<"$ws")    # also keep .result.workspace.workspace_id
herdr agent start "$name" --kind claude --pane "$pane" -- --model opus
"$mail" watch "$name"
herdr agent prompt "$name" "$(cat <<'EOF'
<brief, ending with the protocol below>
EOF
)" --wait --until working --timeout 30000
```

- `--until working` confirms delivery and returns. Start the whole stage before waiting on any
  agent.
- Use another kind, model, or permission mode only when the user names one.
- Install dependencies in the checkout before prompting. Get its path from
  `herdr worktree list --cwd "$PWD"`. Never copy `.env` files into it.
- Never seed a checkout with a patch or share one checkout between agents.
- New work gets a new agent and worktree. Never re-brief a finished agent.

## Protocol

End every brief with this, `$mail` expanded to its absolute path:

> Work only in this checkout. Do not touch git: no commits, pushes, or PRs. To ask the orchestrator a question without
> stopping, run `$mail send parent "<question>"`. Replies arrive as your next prompt. When done,
> send your report with `$mail send parent - <<'EOF'`: files changed, acceptance output,
> blockers, then `EOF`. Then end your turn.

- Wait only through `"$mail" wait` as a background Bash command, never a sleep loop or watcher.
  It prints and exits on the next mail.
  Handle it, then wait again.
- Reply to a child: `"$mail" send "$name" "<text>"`. It arrives when the child is idle. Stop a
  child with `herdr agent send-keys "$name" esc`.
- `[status ... blocked]` means a permission prompt or a question in the child's UI. Read it with
  `herdr agent read "$name" --lines 60`. Answer a question yourself from the plan, with the
  recommended option. Bring a permission prompt to the user. Never approve it yourself.
- A child's commit failure: tell it to stay uncommitted; you integrate the diff.
- `done` without a report: read the agent, then ask it for the report.

## Review and integrate

Get the checkout `path` from `herdr worktree list --cwd "$PWD"` by matching the branch. Review
with `git -C "$path" diff` and run the acceptance commands in the checkout. A wrong approach gets
a fresh scope with a corrected brief. Scopes own disjoint files, so each diff applies cleanly:

```bash
git -C "$path" add -A && git -C "$path" diff --cached --binary | git apply --index
```

## Cleanup

- Remove a worktree as soon as its diff lands or its scope is abandoned.
- Confirm the diff landed, then run `herdr worktree remove --workspace "$ws_id" --force` and
  `git branch -D "scope/$name"`. If `git log "$base..scope/$name"` shows commits, find out why
  first.
- Never use `workspace close`. It leaves the checkout on disk.
- End of run: no containers, simulators, or dev servers started by this run remain.
- End of run: `git worktree prune`. `git worktree list` and `git branch --list 'scope/*'` must
  show nothing from this run.
- `scope/*` worktrees from earlier runs are not yours. List them and ask before removing.
- Never push `scope/*` branches.
