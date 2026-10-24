---
name: design
description: Design and build UI that looks crafted, not generic. Loads Emil Kowalski's and Apple's design skills, studies how the best modern products solve the same job, shows variants before committing, and checks the result on screen. Use for any visual or interaction work on web, mobile, or desktop: a new screen, flow, page, component, icon, animation, redesign, or "this looks bad / generic / not polished".
---

# Design

Design is its own track. Code quality belongs to `dev:subagents`; this skill owns how it looks,
moves, and feels.

## 1. Load the craft skills

Invoke each skill below with the Skill tool at its step. Never skip one or work from memory of it.
All except `expo-native-ui` come from `emilkowalski/skills`. If the Skill tool refuses one as
user-only, read its installed `SKILL.md` and follow it. If one is missing, say so in the report.

- Always, before anything else: `emil-design-eng` and `apple-design`.
- Building motion: `animate` on the web, `animate-expo` in Expo. Expo screens add
  `expo-native-ui`. Phone web apps add `mobile-native`.
- Choosing a frontend library: `pick-ui-library`. Toasts with Sonner: `ask-sonner`.
- Follow them fully. Their taste is the bar: depth, materials, blur, springs, and motion are
  allowed wherever they serve the interface.

## 2. Study modern products

- When the user names a reference app, study it first.
- Look at 3 or more current, best-in-class products doing the same job, such as Linear, Raycast,
  Vercel, Arc, Things, Stripe, Family, and Apple's own apps. Browse real flows on Mobbin or Refero.
- Guidelines, in this order: the current Apple Human Interface Guidelines and WWDC design
  sessions; Emil Kowalski's and Rauno Freiberg's writing; Vercel's Web Interface Guidelines;
  Material 3 Expressive for Android only.
- Never cite or propose GOV.UK, NN/g, Baymard, Laws of UX, or generic UX blogs and courses. They
  describe dated, generic UI.
- Look sources up live and use the current version.
- Take the pattern users already expect, then make it this product's own.

## 3. Show before building

- For a new visual, icon, animation, or screen, build 2 or 3 distinct variants and show them,
  using Emil's `prototype` skill for the picker. Not `mattpocock-skills:prototype`.
- Never ship the first idea as final. Iterate on the user's notes until they approve.
- Keep what the user likes. Change only what they flagged, and add states to existing artwork
  rather than redrawing it.

## 4. Build with care

- Extend the product's own components and tokens. One component per pattern, reused everywhere.
- The current mode and state are always obvious: what is on, what is running, what failed.
- Basic actions take one step. Power features stay reachable but out of the way.
- Nothing jumps: sizes hold across states, loaders fill the same box, and toggles stay in place.
- Motion is interruptible and reverses from where it is. Repeated toggles land on the nearest
  rest position.

## 5. Check it on screen

- Run it in the real app or browser, screenshot every changed screen in both themes and at the
  smallest and largest size, and look at the screenshots before reporting.
- Step through motion: interrupt it, reverse it, toggle it quickly, and turn on reduced motion.
  Then run `review-animations` on the motion code and fix what it flags.
- Asked to audit a whole app's motion: `improve-animations`, and `find-animation-opportunities`
  for places that should move but don't.
