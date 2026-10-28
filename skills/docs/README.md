# docs

Documentation authoring tools.

This bucket is its own Claude Code plugin — `claude plugin install docs@skrrt` — so its skills
are namespaced `/docs:md-writer`.

- **[md-writer](./md-writer/SKILL.md)** — Format and validate the README, architecture, decisions, and plan docs:
  Mermaid diagrams, comparison tables, lint-clean output.

Requires **Node.js 22+** — `markdownlint-cli2` 0.23 dropped end-of-life Node 20. The validator
auto-fixes mechanical rules and reports only what needs judgment. Missing tooling is reported as a
failure, not a clean result. AGENTS.md, CHANGELOG, and SKILL.md are outside the skill's scope.
