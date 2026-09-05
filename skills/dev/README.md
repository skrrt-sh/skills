# dev

Implementation workflow tools.

This bucket is its own Claude Code plugin — `claude plugin install dev@skrrt` — so its skills
are namespaced `/dev:subagents` and `/dev:self-documenting`.

- **[subagents](./subagents/SKILL.md)** — Orchestrate strictly scoped subagents from a main thread that only plans and reviews.
- **[self-documenting](./self-documenting/SKILL.md)** — Keep the code the single source of truth: comments answer why in three lines at most, docs record decisions, instruction files carry how.

The main thread stays on Fable or Opus and holds the judgement — it assesses, decides, briefs,
dispatches, reviews, and pivots; subagents
run on Opus by default, own disjoint sets of files, and leave git alone. Concurrency is capped at
five, so a scope with more parts becomes sequential stages, each reviewed against the real diff
before the next is dispatched.

`self-documenting` fires whenever code, comments, docs, or agent instruction files are written or
edited, even when the request never mentions documentation. Every line of prose is a second copy
of something the code already holds, and copies drift: comments stay rare, answer why rather than
what, and never exceed three lines; docs record architecture and design decisions rather than how
the system works; CLAUDE.md, AGENTS.md, rules and skills carry only how work is done, a few
hundred lines at most, because they load into every message. Prose never points into the code,
since a path, symbol, or line number dangles the moment its target moves. Location is described
only as architecture, the layers a structure such as MVC defines, never as paths.
