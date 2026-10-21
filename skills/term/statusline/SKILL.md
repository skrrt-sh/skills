---
name: statusline
description: Install the skrrt Claude Code status line, a Catppuccin Mocha pill bar showing model, folder, git branch, lines changed, context use, and the 5-hour and weekly rate limits. Use when the user asks to install, set up, update, or restore the skrrt status line.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh:*)
---

# Install the Status Line

## Process

1. Ask the user for a context budget, the token count the context pill treats as full, unless they
   already named one. Make clear it is visual feedback on how efficiently the session uses its
   context: it never caps the model's real window, and nothing breaks past it. Offer:
   - **100k**: strict. Quality drops are reported from about 100k even on 1M-window models.
   - **200k**: balanced. Where Claude Code compacted before 1M windows.
   - **256k** (default): the honest ceiling for decent results. Heavy users of 1M-window models
     report drops between 250k and 400k. Yellow starts at 128k, where quality drops are commonly
     reported.
   - A custom token count.
2. Run `${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh <tokens>`, for example `200000`. It copies
   [assets/statusline.py](assets/statusline.py) to `statusline/statusline.py` in the Claude config
   directory and sets `statusLine` in that directory's `settings.json`, passing the budget to the
   script. To change only the budget later, run it again with the new number.
3. Report `INSTALLED`, `SETTINGS`, and `BUDGET`. If it printed `BACKUP`, name the backup of the
   replaced script. If it printed `PREVIOUS_STATUSLINE`, show the replaced setting so the user can
   restore it.
4. Tell the user the bar appears on the next refresh and its icons need a Nerd Font in the
   terminal.
5. Walk the user through the bar, left to right, using [Reading the bar](#reading-the-bar).

## Reading the bar

- Model, then folder.
- Git branch. Its `+N -M` tail is the uncommitted diff against the last commit, untracked files
  included: what the next commit would ship, whoever wrote it.
- Context: tokens in use against the chosen soft budget. Green below half, yellow from half. Past
  the budget it turns red and reads `new session`: the session still works, but it is time to start
  a fresh one. Outside a git repo it carries the `+N -M` tail instead: lines Claude changed in this
  session, so it lives and resets with the context.
- `5h` and `wk`: rate limit used, with time until reset. Red from 80%.

## Guardrails

- Install only when asked. To change colors or segments, edit the installed script, not the asset,
  unless the user is changing this skill.
- On a missing `python3` or `jq`, report the error and stop; do not edit `settings.json` by hand.
