---
name: subagents
description: Orchestrate subagents to implement code changes. The main thread plans, briefs, dispatches, and reviews. Strictly scoped subagents on Opus write the code. Use for any implementation, audit, or fix that is more than a one-line edit, whenever the user asks for subagents, parallel work, or handing work to agents, even without the word subagent.
---

# Subagents

The main thread plans, briefs, dispatches, and reviews. Subagents write the code.

## Roles

- Main thread: Fable or Opus. On another model, tell the user and offer `/model` before
  dispatching.
- The main thread edits only small review fixes, such as a rename or a missing import. A larger
  fix is a new scope.
- Subagents: `general-purpose` type with `model: "opus"`. Use `sonnet` only if the user asks for a
  cheaper run and the scope is mechanical. An explicit user choice overrides both.
- Never use `fork`. It inherits the main thread's model and context.
- One subagent per scope. Subagents never spawn subagents. At most five running, or the user's
  lower limit. More scopes run in stages.
- Work autonomously. Do not stop to ask; follow the `reporting` skill for questions.
- Inside Herdr (`HERDR_ENV=1`), when scopes need their own checkouts or the user asks for Herdr,
  dispatch with the `herdr-agents` skill instead of `Agent`. All other rules here still apply.

## Process

1. Assess. Fetch first, work from the latest target branch, and check open PRs for overlapping
   work. Send broad reading to an `Explore` subagent on Opus. Check that the plan fits the
   architecture and the codebase's patterns. Correct a wrong plan with the user before briefing.
   Without an outline, draft one and confirm it.
2. Split. A scope is finishable without another scope's in-progress work. Every file belongs to
   exactly one scope. Generated files, such as migrations, lockfiles, and snapshots, belong to one
   scope per stage; regenerate them after integrating. Contracts land in a stage before their
   consumers. Work that cannot be split stays in one scope.
3. Brief. The subagent has none of your context. Brief later stages from what earlier stages
   actually landed: real contracts, signatures, paths. State the goal, the relevant existing code, the
   files it owns, the files off limits, the contracts it builds against, the acceptance command,
   the quality bar, and the report format: files changed, acceptance output, blockers.
4. Dispatch a stage's agents in one message. Then review: read the diff, check file ownership,
   rerun the acceptance commands and the full build, tests, and lint, and check the quality bar.
   Search for an existing component or helper matching each new one; merge duplicates.
   A summary is a claim; the diff is the evidence. Fix small issues yourself. Send larger ones to
   a new subagent with a corrected brief, never back to the one that erred. New work always gets
   a new agent. Before stopping an agent, salvage its diff. Newly found work
   becomes a scope in a later stage. If the evidence shows the approach is wrong, redraw the
   affected scopes, re-brief, and tell the user what changed and why. Only the user changes the
   goal.
5. Finish. Verify every scope item landed, nothing beyond it, and no `HACK:` comment remains in
   the changed code. Report what each stage delivered, named by its content, not its number,
   then the commands run and their output, your fixes, and what remains. Report failures as
   failures.

## Quality bar

Put it in every brief. Enforce it in every review.

- Follow the `design-principles`, `testing`, `self-documenting`, and `research` skills.
- UI scopes: also follow the `design` skill. It owns how the UI looks and moves. A subagent
  returns its variants to the main thread, which shows them to the user and dispatches the
  integration stage only after the user picks one.
- Never read `.env` files, keys, or process lists. Never use the user's servers, databases,
  devices, or ports; start your own and stop them before reporting.
- Never ask the user. Take the recommended option and list the question in the report.
- Do not touch git. The orchestrator owns commits, branches, and pushes.
- Report honestly: failing as failing, skipped as skipped, guesses as guesses.
