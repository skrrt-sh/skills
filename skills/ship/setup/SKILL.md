---
name: setup
description: Configure this repository for the Skrrt ship workflows and select a branching strategy. Run once before commit, pr, and release.
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/configure-ship.sh:*)
---

# Configure Ship Workflows

Create a short agent-instruction pointer and a detailed `.agents/ship.md` policy for this
repository.

## Process

1. Confirm the current directory is a Git repository.
2. The instruction file is always `AGENTS.md` at the repository root; never ask which file to use.
   Claude Code ignores it while `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` exists.
3. Read [references/branching-strategies.md](references/branching-strategies.md). Inspect the
   repository signals it names, then present GitHub Flow, Trunk-Based Development, and Gitflow with
   one evidence-based recommendation. The user makes the final choice: wait for it before writing
   anything, even where other skills say not to ask. If they already named a
   strategy, treat that as their choice after reporting any material mismatch. In the same
   message, state that any existing `CLAUDE.md` or `.claude/CLAUDE.md` will be moved into
   `AGENTS.md` and deleted, so that one confirmation covers both.
4. If `.agents/ship.md` already exists, report its configured strategy before replacing it. Only
   the `skrrt:policy` block is replaced; anything the repository added outside it is kept.
5. From the target repository, run:

   ```text
   ${CLAUDE_SKILL_DIR}/scripts/configure-ship.sh --strategy <github-flow|trunk-based|gitflow>
   ```

   The script appends the content of `CLAUDE.md` and `.claude/CLAUDE.md` to `AGENTS.md`, keeps one
   `skrrt:ship` block, and deletes them. Never migrate them by hand.

6. Report the selected strategy, whether each file changed, and every `MIGRATED_FILE`. If the
   script prints `BLOCKING_FILE=CLAUDE.local.md`, report that this personal file stops Claude Code
   from reading `AGENTS.md`; never edit or delete it.

The script may modify only `AGENTS.md`, the migrated `CLAUDE.md` files, and `.agents/ship.md`. It
preserves content outside Skrrt markers, removes the legacy `skrrt:branching` block, and is safe to
run repeatedly.
