---
name: style
description: Turn reference images into a written art style that reproduces their look without attaching them, proven on unrelated subjects with Higgsfield and frozen in a style file. Use when asked to copy this style, make images in the style of these references, define or lock an art style, or give a set of images one look. Not for rendering the final images (`image`), keeping one object identical across images (`prop`), UI design, video generation, or editing real photos.
---

# Style

Rendering follows `image`. Every prompt is a JSON specification; the style file holds every field
except `subject`.

## 1. References

- Read every reference image. Settle what to take: when the user points at one and says "like
  this", ask or infer the trait, such as finish, colour, or detail level. Take the look, never
  their objects.

## 2. Fields

- `task`: "Photograph one subject for the art set of a website. Every image in the set shares this
  exact look, lighting, camera and background."
- `style`: `medium` (and shape language), `readability` (detail density), `materials` (and
  finish), `colour`, `lighting` (and effects), `focus`.
- `frame`: `view`; `framing`, how much of the frame the subject fills ("sits fully inside the
  frame at about two thirds of its height"); `background`, a flat hex; `shadows`; `exclusions`
  such as no text, no people unless wanted.
- `subject`, written per image: `{"name": "...", "object": "<what it is; each object's material, colour,
  pose; exact counts and geometry>", "around": "<2-3 pieces, or none>", "accent": "<one effect, or
  none>"}`.
- Values are full plain sentences, never keyword lists. Describe what is seen, never genre labels.
  Concrete positive rules, plus only the bans a test proved necessary.
- Colours as vivid names (royal violet, bone white); hex only for the background.
- Material words steer hardest: plastic, toy, matte, or worn can flip the whole look.
- Key names and values can get painted into the image: keep keys neutral and generic, like these.
- A rule for one kind of object goes in that subject, not the fixed fields. Describe nothing from
  the references' contents.
- Icons and illustrations in one set: one style with `scales`. Each scale sets its own
  `readability`, `framing`, aspect ratio and resolution; the rest stays shared. Icons get one
  object, a bold silhouette, no small detail; illustrations may be complex.

## 3. Prove

- With no images attached, render 4-6 unrelated subjects with identical params, at final quality.
- Sheet the renders beside the references and Read it. It passes when they read as one set and as
  the references' style.
- Otherwise change one thing per round, keep each round as a numbered version, and show the user
  each round's sheet.
- Compare models only if asked; a set uses one model. Seeds do not carry a style.

## 4. Freeze

- On approval, write `art/styles/<style>.json`:

  ```json
  {"model": "...", "params": {"aspect_ratio": "...", "...": "..."},
   "task": "...", "style": {...}, "frame": {...},
   "scales": {"icon": {"style": {"readability": "..."}, "frame": {"framing": "..."},
                       "params": {...}}},
   "banned": ["words that broke the look"], "traps": ["short notes"]}
  ```

- Once images exist in a style, never reword it. A change is a new version; existing images are
  re-rendered or stay on the old one.
