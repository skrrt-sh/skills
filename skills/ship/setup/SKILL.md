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
2. Select the first existing instruction file from `CLAUDE.md`, `AGENTS.md`,
   `.claude/CLAUDE.md`, and `.github/AGENTS.md`. If none exists, ask the user whether to create
   `CLAUDE.md` or `AGENTS.md`.
3. Read [references/branching-strategies.md](references/branching-strategies.md). Inspect the
   repository signals it names, then present GitHub Flow, Trunk-Based Development, and Gitflow with
   one evidence-based recommendation. The user makes the final choice. If they already named a
   strategy, treat that as their choice after reporting any material mismatch.
4. If `.agents/ship.md` already exists, report its configured strategy before replacing it.
5. From the target repository, run:

   ```text
   ${CLAUDE_SKILL_DIR}/scripts/configure-ship.sh \
     --instruction-file <path> \
     --strategy <github-flow|trunk-based|gitflow>
   ```

6. Report the instruction file, selected strategy, and whether each file changed.

The script may modify only the selected instruction file and `.agents/ship.md`. It preserves
content outside Skrrt markers, removes the legacy `skrrt:branching` block during migration, and is
safe to run repeatedly.
