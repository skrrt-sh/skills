---
name: self-documenting
description: Keep comments and documentation to the inevitable minimum so the code stays the single source of truth. Comments answer why, three lines at most; docs carry decisions and architecture, never how the system works; CLAUDE.md and AGENTS.md carry conventions, never situational facts; nothing points into the code by path, symbol, or line. Apply whenever writing or editing code, comments, docstrings, READMEs, design docs, CLAUDE.md, AGENTS.md, rules, or skills, even if the request never mentions documentation.
---

# Self-Documenting Code

Code is the single source of truth. Every comment and document is a second copy of a fact the
code holds, and copies drift: the code moves, the prose stays, and the reader gets two accounts
that disagree. Treat every line of prose as a hostile witness and write only what is inevitable.

Docs for decisions, comments for why, CLAUDE.md and AGENTS.md for how. Everything else is code.

Prose never points into the code. A path, a line number, a symbol used as a pointer, a "see also"
dangles the moment its target moves and then leads somewhere stale. State the reason in place.
Location is described only as architecture, the layers a structure such as MVC or hexagonal
defines and the rule for what goes where; without such a structure, say nothing about where things
live. When reading, search the code rather than trust a path a README offers.

## Comments

Write code that needs none: name the value, extract the block into a function named for what the
header would have said, make the invariant a type or an assertion. What is left answers **why**,
never what: the external bug being worked around, the invariant the compiler cannot check, the
trade-off taken on purpose. The reason alone, as short as it can be said, with no description of
the code beneath and no elaboration; three lines at most. Anything longer is a decision for a doc
or code that needs restructuring.

A comment that describes what the code does marks a missing name. Delete it and name the code:

```ts
// Sum the price of every item
for (const item of items) total += item.price;
```

```ts
const total = sumPrices(items);
```

A comment that gives a reason the code cannot show stays, in as few words as possible:

```ts
// Must match Stripe's rounding
const cents = roundHalfEven(amount * 100);
```

Docstrings and JSDoc are comments too: the signature states the parameters, so a docstring earns
its place only by saying what the signature cannot, such as units or failure behaviour. Tool
directives and license headers are not prose; leave them to the tooling. A change that makes an
existing comment false fixes or deletes it in the same change; untouched comments stay unless
asked to clean up.

## Docs

A doc records decisions: the architecture chosen, the alternatives rejected and why, the
constraints that forced the choice. Never how the system works; that is a copy of the code, wrong
after the next change. The test for each paragraph: would a routine code change make it false?
Then it belongs in the code. A few hundred lines per file at most; past that the file is
describing, not deciding. Write a doc only when asked or when a decision was made that the code
cannot show.

## CLAUDE.md, AGENTS.md, rules and skills

Instruction files load into every message and skills whenever they fire, so each line costs
tokens and attention on every turn. They carry **how**: code style, conventions, the settings and
commands that shape how work is done. Situational facts, the state of a migration, last week's
fix, the ticket in flight, belong in git history or the tracker. Keep a line only when the agent
would otherwise do something else. A few hundred lines at most; the directory tree and a
manifest's scripts are lookups, not rules.

## When asked for more

Asked to comment a file, document how a module works, or record a sprint in CLAUDE.md, do the
version that survives the next change: rename and extract instead of narrating, capture decisions
instead of mechanics, keep rules and drop facts. Say in one sentence what you did instead and
where the rest belongs. If the user still wants the narration, it is their code.
