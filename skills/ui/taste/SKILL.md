---
name: taste
description: How a page or screen looks and reads. Use when laying out or reviewing a page, hero, or sections, fixing layout, spacing, typography, fonts, or contrast, when UI looks bad, ugly, sloppy, or like AI slop, or when writing copy, headlines, CTAs, button labels, error and empty-state text, or tone, or text is salesy, cringy, or repetitive. Design process belongs to ux-patterns, states to screens, tokens and components to design-system, motion to motion.
---

# Taste

## Keep

- Change only what the user flagged. Never replace a behavior, asset, or artwork they like with a
  "more correct" one. Add states to existing artwork; never redraw it.
- Reuse the product's type, blocks, and components first. A new ornament is a defect.
- When in doubt, cut: less info, fewer elements, plain values over indicators.
- Perceived speed and a retina-sharp hero beat audit scores. Render OG images from the real
  site, never a screenshot.
- Motion follows `motion`: small CSS accents, never tilts, cursor tracking, or a new library.

## Layout

- One content width for every section, hero and media included.
- Same-colored blocks never touch.
- A title owns its line. Logo bars, proof, and badges stay small.
- Nothing clips or sticks out at a container's corners. Everything sits on the grid, one-off
  CTAs included.
- Air groups content; no dead space or empty blocks. Consecutive sections and page heroes vary
  in composition, with weight balanced across the page.
- Nav stays short, visible, and simple. No hidden links.
- Fix balance by rearranging, never with a new style.

## Type and color

- Same role, same size everywhere, with deliberate line height and paragraph spacing. Body
  lines 45 to 75 characters.
- Load web fonts explicitly, from a CDN or self-hosted, with a system fallback.
- WCAG 2.2 AA contrast, visible focus, targets 24px web, 44pt iOS, 48dp Android.
- Check selection and accents on every colored surface. No default blue selection.

## Restraint

- Cut eyebrows, decorative dots, pills, blobs, and odd underlines.
- A one-off element is not a system. Remove it or make it a pattern.
- No AI-slop defaults: generic gradients, glass, centered hero over three cards.

## Words

- Match the project's voice. Real copy before layout. Never invent facts, numbers, or clients;
  leave `[TODO …]` and report it.
- Write for a newcomer. Define terms first, simple to complex.
- Plain words. No hype (seamless, unlock, elevate) and no AI tells ("Whether you're X or Y",
  triplets, "not just X, it's Y").
- Say each fact once, one name per thing.
- Set the tone of voice for the use case first. Rhythm and punctuation serve it; a dash or
  colon is fine when the flow needs one.
- Buttons are verb plus object: "Book a call", not "Submit". One primary CTA per section.
- An error sits beside its field and gives the fix. An empty state gives the one action that
  fills it.

## Check

- Screenshot the smallest and largest widths in both themes. Report findings as before and after.
- Reread changed strings against Words. List the placeholders left.
- Report only checks you ran. Never describe a page or screenshot you have not seen.
