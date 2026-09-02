# dev

Implementation workflow tools.

This bucket is its own Claude Code plugin — `claude plugin install dev@skrrt` — so its skills
are namespaced `/dev:subagents`.

- **[subagents](./subagents/SKILL.md)** — Orchestrate strictly scoped subagents from a main thread that only plans and reviews.

The main thread stays on Fable or Opus and holds the judgement — it assesses, decides, briefs,
dispatches, reviews, and pivots; subagents
run on Opus by default, own disjoint sets of files, and leave git alone. Concurrency is capped at
five, so a scope with more parts becomes sequential stages, each reviewed against the real diff
before the next is dispatched.
