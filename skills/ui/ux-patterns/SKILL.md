---
name: ux-patterns
description: Design process to run before any UI is drawn or built. Complete user stories for the least-expert and power user, then established patterns from peers and platform guidelines, then product-specific principles, then a design where every element traces to a story, delivered as a short brief in chat. Use when asked to design or redesign anything, for a new feature, screen, flow, page, or landing page, or when asked how something should work or what users expect.
---

# UX Patterns

Design comes from user stories and established patterns, never from preference or novelty. Run the
gates in order.

## 1. Stories

- Name the least-expert user, who has never used this kind of product, and the power user.
- User story: as a, I want, so that. No goal, no feature. Job story when context or anxiety
  matters: when, I want to, so I can.
- Stories pass INVEST. Acceptance criteria are outcomes: done when the user can...
- Each story is complete end to end, failure paths included.
- Map them: activities, then steps (flows, screens), then details (elements).
- Frequency decides visibility: basic in one step, intermediate reachable, power tucked away.
- Split a complex task into stages rather than one crowded screen.

## 2. Patterns

- For a redesign, inspect the real screen first. Never critique one you have not seen.
- Name the platform (mobile, desktop, web app, landing page, e-commerce, docs) and the job
  (form, checkout, onboarding, search, navigation, table, settings, payment).
- Read that platform's section of [platforms.md](references/platforms.md) when researching it;
  re-check the live source when a decision rests on it.
- When the user names a reference product, study it first.
- Study 3 to 5 established products doing the same job: peers users compare with, best in
  class, one adjacent industry. Record how each solves each story; name the dominant pattern.
- Look each one up live and cite links with dates. Memory alone fails this gate.
- Evidence ranks: platform guidelines, then NN/g, Baymard, GOV.UK, then shipped products.
  Screenshot galleries are examples, not evidence. Source per `research`.
- Break a convention only with a stated reason it serves a story better. Never for novelty.

## 3. Principles

- Pick 3 to 5 product-specific principles, each a trade-off (clarity over novelty) that
  settles design conflicts.

## 4. Design

- Every element traces to a story; cut the rest.
- Content first, layout fitted to it.
- The UI explains itself to the least-expert user.
- Delight only on a working flow, in one or two places that serve a story. Polish hides usability
  problems.
- Hand off: `taste` (looks and words), `screens` (states, performance, checks),
  `design-system` (tokens, components), `motion` (animation).

## Brief

- Before building, post in chat: stories, products and guidelines studied with links and dates,
  the pattern per flow and any deliberate break with its reason, the principles.
- No repo file unless asked. In Figma or code, the brief comes first.
- Scale to the change: a small addition gets a quick pattern check (its story, how the platform
  and two peers do it, where frequency puts it). New flows, pages, and redesigns get every gate.
