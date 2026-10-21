---
name: screens
description: Ship each screen complete, predictable, fast, and matched to the design. Every real state handled, one established pattern per action, big flows split into steps, only visible rows rendered, and checks in the real UI on every target. Use when building, changing, or reviewing any screen, page, view, flow, or form on web, mobile, or desktop, and when the UI shows a wrong or stale state, double-fires on repeated taps, lags, or misses a loading, empty, or error state. Design process belongs to ux-patterns, looks and wording to taste, motion to motion.
---

# Screens

A screen is done when every state works, it matches the design, and it holds the display's
refresh rate on the slowest target.

## States

- List every state before building: idle, loading, success, empty, error, disabled, offline.
- The UI shows the real state from its source of truth, including transitions such as connecting
  or failed. Never a stale or optimistic guess.
- Every async action shows a pending state and blocks a double submit. Navigation and push
  actions ignore repeated taps on every screen.
- Loading is not empty. Never flash the empty state on first load; keep stale content while
  refetching. A skeleton matches the final layout and never shows beside the content.
- Hide a section that has nothing to show, unless its empty state guides the user.
- Media reserves its aspect-ratio box with a placeholder. Never crop unless the design does.
- A flow too big for one screen splits into steps, shows every status, and ends on a receipt.
  Back returns where the user came from.

## Patterns

- Run `ux-patterns` before designing a new screen or flow and use the established pattern. Same
  action, same pattern everywhere.
- The main action or information is the most visible thing.
- Basic actions take one step and frequent features stay visible. Power-user and rare ones are
  reachable but tucked away.
- Group settings into meaningful sections. Wording follows `taste`.

## Performance

- Render only what is visible: virtualize long lists and feeds. Build any list a user can grow
  for thousands of items.
- Unchanged rows never re-render. Isolate fast-changing values.
- Pause offscreen or idle animations, timers, and media. Idle UI uses near-zero CPU.

## Fidelity

- Build from the latest design version; a Figma file may hold several. Match layout, spacing,
  type, and assets. Add nothing the design lacks; flag gaps. Motion polish follows `motion`.
- When the design image disagrees with the design system, the system wins. Report it.
- Check every breakpoint and the smallest window. Content stacks before it squeezes; nothing
  jumps on resize.
- Check both themes and every target platform. Match the better platform in the shared component.
- Respect safe areas and system bars. A sticky bottom action pads the content by its height; one
  scroll container per screen.

## Verify

- Run it in the real UI on a production build: a headless browser or simulators for every target.
  Walk every user story end to end and one failure path.
- Compare each changed screen with the design and keep screenshots. Remove anything that drifted
  from the design during the change.
- Force each state with seeded data or a dev-only toggle. Never wait on a slow manual loop.
