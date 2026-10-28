---
name: self-documenting
description: Keep comments and docs minimal so the code stays the single source of truth. Docs are only the README, docs/architecture.md, docs/decisions.md, and a transient plan; never how the code works. AGENTS.md is the only instruction file; a project has no CLAUDE.md. Every change fixes or deletes the prose it makes false. Use whenever writing or editing code, comments, docstrings, READMEs, architecture docs, decisions, ADRs, plans, AGENTS.md, CLAUDE.md, rules, or skills, even if the request never mentions documentation.
---

# Self-Documenting Code

The code is the single source of truth. Every comment and doc is a copy that drifts. Write prose
only when the code cannot say it.

- Docs hold the product, the modules, and the decisions. Comments hold why. AGENTS.md holds how
  to work. Everything else is code.
- Prose never references code by path, symbol, or line number. Describe location only as
  architecture layers, such as MVC, or name a module by its role. Otherwise agents find code by
  searching it.

## Comments

- Replace a comment that says what the code does with a name: rename, extract a named function,
  or encode the invariant as a type or assertion.
- A remaining comment states why: a workaround, an invariant the compiler cannot check, a
  deliberate trade-off. The reason only, three lines at most.
- Before deleting a comment, keep any reason it contains as a one-line why.
- A docstring states only what the signature cannot, such as units or failure behavior, in three
  lines at most.
- Keep tool directives and license headers. Delete a TODO, FIXME, or suppression the change
  resolves.
- Asked to narrate code, rename and extract instead, say so in one sentence, and offer the literal
  version; the user decides.

```ts
// Bad: says what
// Sum the price of every item
for (const item of items) total += item.price;

// Good: the name says what
const total = sumPrices(items);

// Good: says why
// Must match Stripe's rounding
const cents = roundHalfEven(amount * 100);
```

## Docs

A project keeps only these docs:

- `README.md`: the product. What it is, who it is for, the core idea, how to start it.
- `docs/architecture.md`: each module or service, its responsibility, and how they connect, with
  one Mermaid diagram. Name modules by role, never by path, function, or internal detail.
- `docs/decisions.md`: one H2 heading per decision stating it, then one or two lines: what it
  was chosen over and why. No dates, statuses, history, or ADRs.
- `docs/plan-<effort>.md`: transient, one per effort: stages, done, open. Updated in place each
  session.

Rules:

- No how-it-works docs, guides, specs, or runbooks. Delete any section that explains how
  something works; never rewrite it.
- When code and a doc disagree, the code wins: fix or delete the doc line in the same change.
- Delete any paragraph a routine code change would make false.
- Asked for a how-it-works doc, record the decisions and responsibilities instead and ask only
  for missing reasons.
- When the user states a decision the code cannot show, such as a provider or a release path,
  record it in `docs/decisions.md` in the same change, and in AGENTS.md only if it changes
  how to work.
- Delete a plan only when every stage is implemented, never after one stage. Before deleting it,
  move each decision that still holds into `docs/decisions.md`, update the architecture and
  README, and move what is open to the tracker.

## Instruction files

AGENTS.md, rules, and skills load on every turn.

- AGENTS.md is the only instruction file. A project has no CLAUDE.md, `.claude/CLAUDE.md`, or
  CLAUDE.local.md: Claude Code reads AGENTS.md only when none exists. If one exists, move its
  content into AGENTS.md and delete it.
- AGENTS.md answers how to work, for what nearly every thread needs: style guidelines,
  conventions, commands, internal know-how, and what the operator expects.
- Never store the state of the code: current status, notes, progress, recent fixes, tickets, file
  maps, or how the code works. Those belong in the code, git history, the plan, or the tracker.
- Keep a line only if the agent would act differently without it.
- A few hundred lines per file at most.

## Clean up

In every change:

- Fix or delete every comment the change makes false. Update facts it makes false: README
  numbers, feature lists, the repo description.
- Delete every doc and instruction file line that describes the replaced solution or contradicts
  the new decision, and any heading left empty.
- If a recorded decision changed, rewrite it in place: the new choice, what it was chosen over in
  one clause, and the reason the user gave. Never invent reasons; ask. Delete one that no
  longer holds.
- Leave other comments alone unless asked to clean up.
