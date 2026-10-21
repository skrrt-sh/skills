---
name: screens
description: Ship each screen complete, predictable, fast, and matched to the design. Every state handled, the UI showing the real state, established UX patterns, every element earning its place, rendering only what is visible, and checks in the real UI on every target. Use when building, changing, or reviewing any screen, page, view, flow, or form on web, mobile, or desktop, and when the UI shows a wrong or stale state, double-fires on repeated taps, lags, or misses a loading, empty, or error state. Motion belongs to the animation skills.
---

# Screens

A screen is done when every state works, it matches the design, and it holds frame rate on the
slowest target.

## States

- List every state before building: idle, loading, success, empty, error, disabled, offline.
- The UI shows the real state from its source of truth, including transitions such as connecting
  or failed. Never a stale or optimistic guess.
- Every async action shows a pending state and blocks a double submit. Navigation actions ignore
  repeated taps.
- Loading is not empty. Never flash the empty state on first load; keep stale content while
  refetching. A skeleton matches the final layout and never shows beside the content.
- Hide a section that has nothing to show, unless its empty state guides the user.
- Media reserves its aspect-ratio box and shows a placeholder first. Never crop unless the design
  does.

## Patterns

- Use the convention users already know for the job: selector, menu, tabs, pull to refresh. Same
  action, same pattern everywhere. Follow the platform guidelines.
- Every element earns its place. Cut captions, badges, and decoration that carry no information.
- The main action or information is the most visible thing. Fix balance by rearranging, never by
  new styles.
- Basic actions take one step. Advanced ones are reachable but tucked away.
- Labels say exactly what happens, in plain words. Say each thing once per screen.
- Group settings into meaningful sections.

## Performance

- Hold the display's refresh rate on the slowest supported device.
- Render only what is visible: virtualize long lists and feeds. Build any list a user can grow
  for thousands of items.
- Unchanged rows never re-render. Isolate fast-changing values.
- Pause offscreen or idle animations, timers, and media. Idle UI uses near-zero CPU.

## Fidelity

- Build from the latest version of the design. Match layout, spacing, type, and assets. Add
  nothing the design lacks; flag gaps instead of filling them.
- Check every breakpoint and the smallest window. Content stacks before it squeezes; nothing
  jumps on resize. Web and desktop.
- Check both themes and every target platform. Match the better platform in the shared component.

## Verify

- Run it in the real UI: a headless browser or simulators for every target. Walk the main task
  and one failure path.
- Compare each changed screen with the design, screen by screen, and keep screenshots as
  evidence.
- Force each state with seeded data or a dev-only toggle. Never wait on a slow manual loop.
