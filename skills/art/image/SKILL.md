---
name: image
description: Generate a consistent set of images (illustrations, icons, compositions) with Higgsfield from a style file and prop references, and check each before showing it. Owns the render mechanics `style` and `prop` reuse. Use when asked to generate illustrations, icons, or images for a site, app, or deliverable, or to regenerate or fix one. Not for writing a style from references (`style`), making one object identical from every angle (`prop`), UI design, video generation, or editing real photos.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh:*)
---

# Image

Files: `art/styles/`, `art/props/`, and `art/work/` for raw renders and `jobs.jsonl`, unless the
project has its own art folder. Never `/tmp`.

## 1. Plan

- Use the Higgsfield connector's tools when the session has them, else the `higgsfield` CLI.
  Credits: `balance`, or `higgsfield account status` (signed out: the user runs
  `higgsfield auth login`).
- No style file yet: use `style`. Every object or person shown in more than one image becomes a
  prop first, with `prop`.

## 2. Prompt

- Every prompt is a JSON specification. Per image write `art/work/<name>.subject.json`:
  `references` only with attached images; `subject` with exact counts and geometry (which face
  points at the camera, how many per row, what is empty); `frame` only for a prop angle's `view`
  or a cut-out's background. The rest comes from the style file unchanged (`--arg scale ''`
  without scales):

  ```bash
  jq -n --arg scale icon 'input as $s | input as $i | $s.scales[$scale] as $c | {references: $i.references,
    task: $s.task, subject: $i.subject, style: ($s.style + $c.style), frame: ($s.frame + $c.frame + $i.frame)}
    | del(.. | nulls)' art/styles/<style>.json art/work/<name>.subject.json > art/work/<name>.json
  ```

- Attach only what this image shows. `references` names each by position with a role: "Image 1:
  the case itself: keep its shape, proportions, material and colours identical; ignore its pose."
- Repeat a prop's identity paragraph verbatim each time it is named. State sizes: "each exactly
  the size of the bar in image 1".
- Never mention an object this image lacks, even to forbid it: the model adds it.

## 3. Render

- Model and params (a scale's over the style's) come from the style file, fixed for the set.
  Default `nano_banana_2_1`, `thinking_level` high; illustrations 4:3 at 2k, icons 1:1 at 1k;
  `nano_banana_pro` for photo scenes with people.
- 2-3 takes per image. Quote the cost (`estimate_image_cost`, or `--cost`) before any batch over
  ~20 credits. Credits short: stop and ask; never fall back to a local edit.
- Connector:
  - `medias` `{role: "image_references", value}`: an earlier render's job id, or a local file
    through `media_upload` (run its curl PUT) and `media_confirm`. Never a URL.
  - `generate_image_batch`, at most 8 requests a call, `prompt` from `--prompt`. `unlim_choice`:
    ask the user which balance pays. Rate-limited: resend only the failed indexes. Timed out:
    outcome unknown, never resubmit blindly.
  - `--log` each job id straight after the submit; `jobs_wait` until all are terminal, reporting
    failed jobs' errors; `--fetch` each full PNG URL, never a `_min` preview.
- No connector tools: the CLI, one job per call, at most 6 at once (`&`, then `wait`); each logs
  to `jobs.jsonl` first and prints the PNG path. `<params>` are `--<param> <value>` flags.

  ```bash
  ${CLAUDE_SKILL_DIR}/scripts/render.sh --prompt <prompt-file>
  ${CLAUDE_SKILL_DIR}/scripts/render.sh --log <model> <name> <job-id> <prompt-file> art/work <params>
  ${CLAUDE_SKILL_DIR}/scripts/render.sh --fetch <name> <job-id> <result-url> art/work
  ${CLAUDE_SKILL_DIR}/scripts/render.sh <model> <name> <prompt-file> art/work <params> --image <ref>
  ${CLAUDE_SKILL_DIR}/scripts/render.sh --cost <model> <prompt-file> <params>
  ```

## 4. Check

- Sheet: `magick montage -label '%t' -geometry 480x480+8+8 -tile 4x <pngs> art/work/sheet.png`.
  Read it and each image at full size: counts and geometry, props match their masters, nothing
  unasked for, no stray text, fully in frame, readable at display size, matches the set.
- Re-render misses; the same prompt often lands on a retry. Show the sheet and flag doubts.

## 5. Change

- Any change to what an image shows is a new render, never a local recolour, cut, or pixel edit.
- Fixing an approved image: attach it with a prompt of only `references` ("Image 1: the approved
  image") and `task` ("Edit this image. <change>. Keep the rest exactly as it is: <list>.").
  Re-render its siblings in a matching set. Past two chained edits images go soft: go back to the
  sharp original.

## 6. Deliver

- Cut-outs (no Nano Banana model outputs transparency): `frame.background` a flat pure `#00FF00`,
  `frame.shadows` none, nothing green or clear glass; then
  `magick in.png -fuzz 15% -transparent '#00FF00' out.png`. Higgsfield's background remover erases
  flames and particles.
- Copy winners into the project's assets. Raw renders and `jobs.jsonl` stay in `art/work/`.
