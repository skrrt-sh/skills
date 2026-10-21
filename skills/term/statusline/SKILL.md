---
name: statusline
description: Install the skrrt Claude Code status line, a Catppuccin Mocha pill bar showing model, folder, git branch, lines changed, context use, and the 5-hour and weekly rate limits. Use when the user asks to install, set up, update, or restore the skrrt status line.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh:*)
---

# Install the Status Line

## Process

1. Run `${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh`. It copies
   [assets/statusline.py](assets/statusline.py) to `statusline/statusline.py` in the Claude config
   directory and sets `statusLine` in that directory's `settings.json`.
2. Report `INSTALLED` and `SETTINGS`. If it printed `BACKUP`, name the backup of the replaced
   script. If it printed `PREVIOUS_STATUSLINE`, show the replaced setting so the user can restore
   it.
3. Tell the user the bar appears on the next refresh and its icons need a Nerd Font in the
   terminal.

## Guardrails

- Install only when asked. To change colors or segments, edit the installed script, not the asset,
  unless the user is changing this skill.
- On a missing `python3` or `jq`, report the error and stop; do not edit `settings.json` by hand.
