---
name: design-system
description: Keep every screen inside one visual system so a fix in one place fixes it everywhere. Tokens, one component per pattern, full component states, stable sizes, consistent spacing, one icon set, close controls on every overlay, and system-level fixes. Use for any UI change on web, mobile, or desktop: building or editing components, screens, themes, tokens, icons, toasts, modals, or sheets, and when matching a design file. Motion belongs to the animation skills.
---

# Design System

One system. Every fix lands in the system, not on a screen.

## Adopt

- Find the existing system first: theme, tokens, component library. Extend it in its own style.
  Never start a second one.
- Search for an existing component before building one. Reuse it or add a variant.
- When a design file disagrees with the system, the system wins. Report the difference.

## Tokens

- Every color, spacing, radius, type style, shadow, and duration comes from a token. A raw value
  only for an optical nudge, with a why comment.
- A new token ships with a rule for where it is used. Snap near-duplicates to the nearest step.
  Delete unused tokens.
- Every surface and input token has a dark-mode pair. Inputs stay distinct from their container
  in both themes.

## Components

- One component per pattern across the app: loader, empty state, error and retry, toast, modal
  shell, collapsible, tabs. A second copy is a defect to merge.
- Every component defines its variants, sizes, and states: default, pressed, focus, disabled,
  loading, error, selected. Hover on web and desktop only.
- Different jobs look different: an action button, a selector with a chevron, a toggle, and tabs
  never look alike.
- Every modal, sheet, and full-screen view has a visible close control plus the platform dismiss.
- Fix a defect in the token or component, then check every screen that uses it. Name each
  checked and changed screen in the report.

## Layout

- Sizes never change with state or content. Inputs, buttons, and badges keep a fixed height.
  Changing numbers use tabular figures. A loader replaces content inside the same box.
- Peer screens share content width, edge padding, and top gap. Peer cards keep the same size
  whatever their content.
- Treat design pixel values as intent. Build flexible layouts that adapt to every size.
- No clipped text: line height leaves room for descenders.

## Icons and decoration

- One icon set, one stroke weight, sizes from the scale. No emoji as icons. Different things get
  different icons.
- Separators, dividers, and badges each have one style in the system.
- No effect the system does not already use: blur, shadow, gradient, transparency.

## Feedback

- Choose the surface by weight: inline for field errors, a change in place for the main result,
  a toast for confirmations that do not block. Toasts come from the system.
- Show each state once, in one place. Never repeat the same status in several spots.

## Gallery

- Keep a dev-only page that renders every component in every state. Review new states there.
