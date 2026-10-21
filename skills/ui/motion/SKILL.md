---
name: motion
description: The project's motion settings on top of Emil Kowalski's and Apple's motion skills, loaded when installed. Use when adding, changing, reviewing, or auditing any animation, transition, hover, gesture, swipe, spring, or haptic, or when something snaps, jumps, or feels janky, on web or Expo/React Native.
---

# Motion

Installed skills teach technique; they never license adding or replacing motion. These settings
win on conflict.

## Load

- Load `emil-design-eng`, `apple-design`, and `animate` (web) or `animate-expo` (Expo) if
  installed. Reviews add `review-animations`; audits add `improve-animations` or
  `find-animation-opportunities`.

## Keep

- Change only the motion the user flagged. Never swap a working animation for a "more correct"
  Emil or Apple one.
- Prefer native mechanisms (CSS scroll snap, native scroll, platform sheets) over hand-rolled
  JS timers.

## Restraint

- Animate as little as possible. Each animation is a small, sharp accent.
- Hover feedback is subtle and short; nothing under the cursor moves. No decorative motion such
  as glow sweeps or tilts.
- Tab switches never slide. No haptic on a plain button.

## System

- The product's design system beats Emil's and Apple's defaults. Never add blur, glass,
  translucency, or shadow it lacks.
- Unspecified polish, like a press scale, goes only in the shared component.
- One motion language: the same kind of transition uses the same token curve and duration.
  A new motion copies the closest existing one.

## Behavior

- Un-hover, cancel, and toggle-off reverse from the current state. Nothing snaps. Repeated
  toggles land on the nearest valid position.
- Gestures track the finger and snap to the nearest point in the direction of travel. A weak
  swipe springs back, faster than a commit.
- Link, nav, and text motion lives only in the system's button and link components, so every
  instance matches. A one-off CTA may differ but stays on the grid. Icons never animate.
- Animate an image or font in only after it loads, with no first-frame jump.
- Hold 60 to 120 fps on low-end Android and old devices; `screens` owns the rest.

## Verify

- Record or step through it in a real browser or simulator: interrupt, reverse, repeated
  toggles, weak and strong swipes, reduced motion.

## Audit

- Build one inventory: element, trigger, curve, duration, token. Flag mismatches, raw values,
  and effects the system lacks. Fix them in tokens or shared components.
