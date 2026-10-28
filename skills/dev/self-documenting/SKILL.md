---
name: self-documenting
description: Keep comments and docs minimal so the code stays the single source of truth. Docs are only the README, docs/architecture.md, docs/decisions.md, and a transient plan; never how the code works. AGENTS.md is the only instruction file. Every change fixes or deletes the prose it makes false. Use whenever writing or editing code, comments, docstrings, READMEs, architecture docs, decisions, ADRs, plans, AGENTS.md, CLAUDE.md, rules, or skills, even if the request never mentions documentation.
---

# Self-Documenting Code

The code is the single source of truth. Every comment and doc is a copy that drifts. Write prose
only when the code cannot say it.

- Docs hold the product, the modules, and the decisions. Comments hold why. AGENTS.md holds how
  to work. Everything else is code.
- Prose never points into the code by path, symbol, or line number. Name a module by role or
  architecture layer, such as MVC; agents search for the rest.

## Comments

- Replace a comment that says what the code does with a name: rename, extract a named function,
  or encode the invariant as a type or assertion.
- A remaining comment states why: a workaround, an invariant the compiler cannot check, a
  deliberate trade-off. The reason only, three lines at most.
- Before deleting a comment, keep its reason as a one-line why.
- A docstring states only what the signature cannot, such as units or failure behavior, in three
  lines at most.
- Keep tool directives and license headers. Delete a TODO, FIXME, or suppression the change
  resolves.
- Asked to narrate code, rename and extract instead, say so in one sentence, and offer the literal
  version; the user decides.

## Docs

A project keeps only these docs. The first three are long-term; only the plan holds short-term
work:

- `README.md`: the product. What it is, who it is for, the core idea, how to start it.
- `docs/architecture.md`: each module or service by role, its responsibility, and how they
  connect, with one Mermaid diagram.
- `docs/decisions.md`: only decisions the user made or approved. One H2 heading per decision
  stating it, then one or two lines: what it was chosen over, clear without other context, then
  why. No dates, statuses, history, or ADRs.
- `docs/plan-<effort>.md`: one per effort: stages, done, open. Updated in place each
  session.

Rules:

- No how-it-works docs, guides, specs, or runbooks; asked for one, record the decisions and
  responsibilities instead. Delete any section that explains how something works; never rewrite
  it.
- When code and a doc disagree, the code wins: fix or delete the doc line in the same change.
- Delete any paragraph a routine code change would make false.
- Asked for a spec, PRD, or requirements doc before the code exists, put the product in the
  README, the decisions in `docs/decisions.md`, and the rest in a plan.
- Record a decision the user states that the code cannot show, such as a provider, in
  `docs/decisions.md` in the same change, AGENTS.md only if it changes how to work.
- A decision the agent took waits in the plan's open list, marked for approval.
- No placeholders such as "pending" or "TBD". With no reason given, omit the why and put the
  question in the report.
- Delete a plan only once every stage is implemented. Before deleting it, move each approved
  decision into `docs/decisions.md`, update the architecture and README, and move what is open
  to the tracker.

## Instruction files

AGENTS.md, rules, and skills load on every turn.

- AGENTS.md is the only instruction file. Move any CLAUDE.md or `.claude/CLAUDE.md` into
  AGENTS.md and delete it. Never move, edit, or delete CLAUDE.local.md; report that it stops
  Claude Code from reading AGENTS.md.
- AGENTS.md holds how to work that nearly every thread needs: style, conventions, commands,
  internal know-how, and what the operator expects.
- Never store the state of the code, such as status, notes, progress, recent fixes, tickets, file
  maps, or how it works; that belongs in the code, git history, the plan, or the tracker.
- Keep a line only if the agent would act differently without it.
- A few hundred lines per file at most.

## Clean up

In every change:

- Fix or delete every comment and fact the change makes false, such as README numbers, feature
  lists, and the repo description.
- Delete every doc and instruction file line that describes the replaced solution or contradicts
  the new decision, and any heading left empty.
- Rewrite a changed decision in place, same format. Never invent reasons.
- When a plan is deleted or `docs/decisions.md` changes, drop decisions the code makes obvious,
  that no longer hold, or on removed features. Keep only what an agent would get wrong or
  reopen.
- Leave other comments alone unless asked to clean up.
