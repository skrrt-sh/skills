---
name: design-system
description: Keep every screen inside one visual system so a fix in one place fixes it everywhere. Tokens, one component per pattern with full states, stable sizes, one icon set, close controls on every overlay, and fixes in the system. Use for any UI change on web, mobile, or desktop: building or editing components, screens, themes, tokens, icons, toasts, modals, or sheets, and when matching a design file. Looks and wording belong to taste, motion to motion.
---

# Design System

One system. Every fix lands in the system, not on a screen.

## Adopt

- Find the existing system first: theme, tokens, component library. Extend it in its own style.
  Never start a second one.
- Search for an existing component before building one. Reuse it or add a variant.
- When a design file disagrees with the system, the system wins; report the difference. An
  approved change lands in the system, never on one screen.

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
  loading, error, selected. Hover only under `(hover: hover) and (pointer: fine)`, never by
  device type.
- Different jobs look different: an action button, a selector with a chevron, a toggle, and tabs
  never look alike.
- Every modal, sheet, and full-screen view has a visible close control plus the platform dismiss.
- Fix a defect in the token or component, then check every screen using it. Name each checked
  and changed screen in the report.

## Layout

- Sizes never change with state or content. Inputs, buttons, and badges keep a fixed height.
  Changing numbers use tabular figures. A loader replaces content inside the same box.
- Peer screens share content width, edge padding, and top gap. Peer cards keep the same size
  whatever their content.
- Design pixel values are intent; layouts flex to every size.
- No clipped text: line height leaves room for descenders.

## Icons and decoration

- One static icon library (Lucide, Heroicons; Simple Icons for brands), one color and stroke
  weight, sizes from the scale. No emoji, hand-drawn arrows, or animated icons. Check glyphs at
  real size. Different things get different icons.
- Separate items with a gap, color, or background, chosen per use case. Never dots; slashes
  rarely. Separators, dividers, and badges each have one style.
- No blur, shadow, gradient, or transparency the system does not already use, even when a design
  or motion skill recommends one.

## Feedback

- Choose the surface by weight: a change in place for the main result, a toast for confirmations
  that do not block.
- Mark a failing field itself with a red outline or badge, never only a banner list.
- Show each state once, in one place.

## Gallery

- Keep a dev-only page that renders every component in every state. Review new states there.
