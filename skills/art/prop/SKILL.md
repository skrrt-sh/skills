---
name: prop
description: Build a prop, an object that must look identical (shape, colours, material, marks) in every image of a set, rendered with Higgsfield as a master plus every angle for `image` to attach. Use when asked to keep an object or character the same in every image, render it from all angles, make a turnaround or reference sheet for an object, or add a colour or open/closed variant. Not for writing a style (`style`), generating final illustrations (`image`), UI design, video generation, or editing real photos.
---

# Prop

Rendering and the JSON prompt follow `image`. Files: `art/props/<prop>/` with `prop.json`,
`master.png`, and `<angle>.png`.

## 1. Identity paragraph

- Write it first: geometry with proportions and counts ("exactly three times as long as it is
  wide", "six pockets in two rows of three"), material, colours as fixed vivid names, marks.
- It is frozen: it is `subject.object` verbatim in every prompt. Drift such as red tag, then
  orange tag, breaks the match.

## 2. Master

- The prop alone in the project's style file: `around` and `accent` none, `frame.view` a
  three-quarter view, `frame.shadows` no cast shadow, the flat plain background. 3 takes; the user
  picks; save as `master.png`.
- A shape words cannot hold, such as a logo: attach a flat drawing with the `references` role
  "Image 1: shape only: rebuild it as the real object".

## 3. Angles

- One render per angle: the master attached with the `references` role "Image 1: the object
  itself: keep its shape, proportions, material and colours identical. Its camera angle is wrong
  for this picture: ignore its pose and follow frame.view exactly.", `frame.view` set to the angle
  sentence, and the identity paragraph.
- Angles: front, three-quarter-left, three-quarter-right, side, back, top, plus a tilted in-motion
  pose if the prop moves in scenes. Write each as geometry:
  - "Rotated 45 degrees about its vertical axis so the front points towards the left edge of the
    frame; the front is foreshortened to about two thirds of its width."
  - "Rotated 80 degrees, almost edge-on: the side wall is the main thing visible."
- A reference pins its pose. An angle that keeps missing gets a second image with the role "Image
  2: pose reference only: take nothing from it but the pose."

## 4. Check

- One sheet of master and angles. Compare each with the master: colour, material, proportions,
  counts, marks. Re-render misses, never pixel-edit. Show the sheet for approval.

## 5. Variants

- Attach the master; `subject.object` is the identity paragraph verbatim plus only the change:
  "Only the body colour changes, from violet to pink."
- A prop containing another prop is rendered with that prop attached.

## 6. Save and use

- `prop.json`:

  ```json
  {"style": "<style>", "model": "<model>", "object": "<identity paragraph>",
   "angles": {"front": "<frame.view sentence>", "...": "..."},
   "jobs": {"master": "<job id>", "...": "..."}}
  ```

- In a scene, attach the angle closest to its view: always one of these renders, never a scene
  crop or a render of a render.
- A reference passes on its background colour, so prop renders stay on the flat background.
