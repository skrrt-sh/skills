# docs

Documentation authoring tools.

This bucket is its own Claude Code plugin — `claude plugin install docs@skrrt` — so its skills
are namespaced `/docs:md-writer`.

- **[md-writer](./md-writer/SKILL.md)** — Structured markdown: YAML frontmatter, Mermaid diagrams, lint-clean output.

Requires **Node.js 22+** — `markdownlint-cli2` 0.23 dropped end-of-life Node 20. The validator
auto-fixes the mechanical lint rules in place and reports back only what needs judgment.
