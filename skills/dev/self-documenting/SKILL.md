---
name: self-documenting
description: Keep comments and docs to the minimum so the code stays the single source of truth. Comments state why in three lines at most. Docs record decisions, never how the code works. AGENTS.md is the only instruction file and holds how to work, never the state of the code. Prose never points into the code. Every change fixes or deletes the prose it makes false. Use whenever writing or editing code, comments, docstrings, READMEs, design docs, AGENTS.md, CLAUDE.md, rules, or skills, even if the request never mentions documentation.
---

# Self-Documenting Code

The code is the single source of truth. Every comment and doc is a copy that drifts. Write prose
only when the code cannot say it.

- Docs hold decisions. Comments hold why. AGENTS.md holds how to work. Everything else is code.
- Prose never references code by path, symbol, or line number. Describe location only as
  architecture layers, such as MVC. Without such layers, do not describe location;
  agents find code by searching it.

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

- A doc records decisions: the architecture chosen, alternatives rejected, constraints. Never how
  the code works.
- A section that explains how something works is invalid in any doc or README. Delete it. Never
  rewrite it.
- Test each paragraph: would a routine code change make it false? Then delete it.
- Write a doc only when asked or when a decision was made that the code cannot show. Asked for a
  how-it-works doc, record the decisions and constraints instead and ask only for missing reasons.
- One current plan doc per effort. Update it in place at the end of each session: decisions,
  done, open. When the work ships, delete it and move what is open to the tracker.
- When the user states a decision the code cannot show, such as a provider or a release path,
  record it in AGENTS.md or the plan in the same change.

## Instruction files

AGENTS.md, rules, and skills load on every turn.

- AGENTS.md is the only instruction file. CLAUDE.md contains only the line `@AGENTS.md`. Move
  any other CLAUDE.md content into AGENTS.md.
- AGENTS.md answers how to work, for what nearly every thread needs: style guidelines,
  conventions, commands, internal know-how, and what the operator expects. It lets the agent
  start without guessing what the operator wants.
- Never store the state of the code: current status, notes, progress, recent fixes, tickets, file
  maps, or how the code works. Those belong in the code, git history, or the tracker.
- Keep a line only if the agent would act differently without it.
- A few hundred lines per file at most, for docs and instruction files alike.

## Clean up

In every change:

- Fix or delete every comment the change makes false. Update facts it makes false: README
  numbers, feature lists, the repo description.
- Delete every doc, README, and instruction file line that describes the replaced solution or
  contradicts the new decision. Write no replacement. Delete a heading left empty.
- If a recorded decision changed, replace it with the new decision and the reasons the user gave.
  Never invent reasons; ask. One decision, one statement.
- Leave other comments alone unless asked to clean up.
