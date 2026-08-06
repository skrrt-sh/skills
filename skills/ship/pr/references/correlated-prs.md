# Correlated review requests

Use this section only when one change requires review requests in multiple repositories or
independently deployed applications.

Add a `## Related PRs` section to each request. Use `owner/repo#N` for GitHub and
`group/project!N` for GitLab:

- `depends on` — the linked request must merge first.
- `required by` — the linked request needs this one first.
- `related to` — no strict order; use this when no dependency is proven.

Keep links bidirectional. After creating a sibling, update the still-open requests. Do not invent a
merge order. Report merged siblings as completed rather than repeatedly editing closed requests.
