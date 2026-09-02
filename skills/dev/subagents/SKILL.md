---
name: subagents
description: Orchestrate subagents to implement a multi-part scope — the main thread plans, briefs, dispatches, and reviews; strictly scoped subagents on Opus write the code. Use whenever the user asks for subagents, parallel or fan-out implementation, or handing work to agents, and for any plan with several independent parts they want done at once, even without the word subagent.
---

# Subagent Development

The main thread holds the judgement — it assesses, decides, briefs, dispatches, reviews, and
pivots; the implementation comes from subagents. The split is the point: an orchestrator that
keeps its hands off the code keeps its context for the decisions, and a subagent that owns one
bounded scope cannot drift into another's.

## Roles

- Main thread: Fable or Opus. On anything else, say so and offer `/model` before dispatching. It
  owns every call on direction, and edits only to review-fix — a rename, a missed import;
  anything larger is a scope.
- Subagents: `model: "opus"` on every `Agent` call — `sonnet` when the user asks for a cheaper
  run and the scope is mechanical. An explicit user choice overrides both.
- Start each subagent fresh, the default `general-purpose` type. A fork inherits the main
  thread's model and context, so the override is silently dropped and scopes bleed.
- One subagent per scope; at most five in flight, or the lower number the user names. More
  scopes than that means stages.

## Process

1. Assess before anything is cut — the system and the plan both. The system: its architecture,
   its conventions, the actual state of what the scope touches; broad reading goes to a read-only
   `Explore` subagent on Opus, since the main thread's context is for decisions, briefs, and
   reviews. The plan: does it fit what you found, is its approach the right one, does it follow
   the established patterns of the codebase and its stack rather than introduce an anti-pattern.
   Whatever is wrong is corrected here, with the user, before it becomes anyone's brief. Without an
   outline, draft one from the assessment and confirm it.
2. Cut the scope along the seams the codebase already has. The test of a scope: one agent finishes
   it without reading another's in-flight work, and every file belongs to exactly one scope.
   Contracts other scopes build on land in a stage before their consumers; work that will not
   partition stays with one agent.
3. Brief each subagent. It starts with none of your context, so a brief is markedly more specific
   than an ordinary task prompt and covers: the goal, what already exists and where, the files it
   owns and the files off limits, the contracts other scopes are built against, the command that
   proves acceptance, the quality bar below, and a short report-back — files changed, acceptance
   output, blockers. Shape it to the task; the coverage is what matters.
4. Dispatch the stage's agents in a single message so they run concurrently, then review the
   stage yourself: the diff, touched files against their owners, the acceptance commands and the
   whole-tree build, test, and lint rerun, the quality bar. A subagent's summary is a claim; the
   diff is the evidence. Fix the small and local; send anything larger back out as a fresh
   subagent with a corrected brief — the agent that erred still carries the reasoning behind the
   error. Work discovered along the way becomes a new scope in a later stage. When the evidence
   says the path is wrong — a contract that will not hold, an approach the code resists — pivot:
   redraw the affected scopes, re-brief, and tell the user what changed and why. Only a change to
   the goal itself is theirs to make.
5. After the last stage passes, check the whole against the written scope: every item landed,
   nothing beyond it. Report what each stage produced, the commands you ran and their results,
   what you fixed, and what remains — failing tests as failing, with their output.

## Quality bar

Pass it into every brief and hold every review to it:

- Implement exactly the scope: no speculative abstraction, no unrequested features.
- Smallest diff that does the job; match the surrounding code's style and idiom.
- Let the code speak for itself. Comment only what the code cannot say.
- Leave git alone — the orchestrator owns commits, branches, and pushes.
- Report honestly: failing tests as failing, skipped work as skipped, guesses as guesses.
