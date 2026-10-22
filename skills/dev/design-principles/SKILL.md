---
name: design-principles
description: Rules for writing and changing code. DRY, loose coupling, separation of concerns, the simplest design, root-cause fixes, complete state machines, no destructive changes, and deleting the code a change replaces. Use when implementing a feature, fixing a bug, refactoring, replacing an approach, adding a module, or planning a large change.
---

# Design Principles

Goal: every future change touches one place.

## DRY

- One home per fact: rule, constant, schema, mapping. Derive everything else from it.
- Search before writing a helper, type, or constant. Extend the existing one.
- Merge only code that changes for the same reason. Tell the user why when you keep look-alikes
  apart.
- Share only the shared fact, such as a format or a calculation. Required-field and permission
  checks are caller policy and stay in each caller.
- Abstract at the third real use, not before.

## Coupling

- Modules interact only through explicit contracts: public functions, interfaces, typed messages.
- Never access another module's internals or private state.
- Inject dependencies. Construct concrete collaborators only at the composition root.
- Pass plain values across module boundaries.
- Type strictly: no `any`, typed errors.

## Separation of concerns

- One reason to change per module. Keep transport, persistence, domain, and presentation apart.
- Organize code by feature. Only truly shared code lives in a shared module.
- I/O stays at the edges. Business logic is pure: no network, disk, or clock access.
- Use the existing architecture. A new one requires the user's approval.

## Simplicity

- Choose the simplest design that meets the goal. Justify every new service, layer, dependency,
  and option, or leave it out.
- Use the widely adopted standard, format, and name. Invent one only when none fits.
- Get it working plainly first. Optimize after, with measurements.
- Weigh the price of every paid API call and host. Never refetch stored data; batch, cache, and
  make jobs incremental and idempotent.
- Use events, not polling.

## Fixes

- Fix the root cause at the shared component. Never hide the symptom with a one-off flag, guard,
  special case, swallowed error, sleep around a race, cast, suppression, or edited generated code.
- Fix the class of bug, not the instance: a stricter type, one validated entry point, or a check.
- Find every similar occurrence and fix them all.
- Exception: a hack commented `HACK:` may bridge stages of a staged change. A cleanup stage
  deletes them all.
- Fix every in-scope issue you find, small ones included.
- After two failed fixes for the same symptom, stop patching. Find the root cause with evidence.

## State

- Every state machine has the fewest states that cover every case. Each state and transition is
  defined and handled, and no two states collide.
- Nothing fails silently.

## Scope

- Follow the decisions recorded in the plan, docs, and AGENTS.md. Never diverge silently.
- Use exactly the framework, tool, and environment the user named. Before choosing any approach,
  including build, deploy, config, or tooling, check what the project already uses and follow it.
- When the ask is a question, plan, or doc, deliver that and change no code.
- No mock or placeholder in place of the real integration unless asked. An asked-for mock sits
  behind the real interface, in one module, marked with a TODO.
- Before changing a screen or module, list its features. Each must still work after.
- Work only on the current stage. Leave deferred work deferred.
- Implement only what was asked. No speculative options or features, and no convenience behavior
  the user did not specify, such as case-insensitive matching.
- Smallest diff. Match the surrounding style.
- If the structure blocks the feature, refactor first as a separate step with identical behavior.

## Cleanup

The new solution replaces the old one in the same change.

- Delete the replaced code and its call sites, flags, config, fallbacks, and shims.
- Delete what the change left unused: functions, types, imports, dependencies, files. Search for
  references first.
- No commented-out code. No `_old`, `v2`, or legacy copies. Git keeps history.
- Keep an old path only if the user asks or deployed clients depend on it. Before launch, change
  schemas in place: no backfills or compatibility paths.
- Tests follow the `testing` skill. Comments and docs follow the `self-documenting` skill. UI
  follows the `ui` skills.

## Safety

- Never delete user-owned records or data that is costly to regenerate. Anonymize, tag, or
  archive instead.
- Never drop uncommitted work. Branch it instead.
- Never change global config unless the user asks.
- Never read `.env` files, environment variables, or process lists unless the user points at
  them.
- Remove every process, container, and temp file you started outside the repo.
