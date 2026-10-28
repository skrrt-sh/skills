# Decisions

## Skill frontmatter allows only `name`, `description`, `allowed-tools`, and `disable-model-invocation`

Chosen over the wider set of Claude Code frontmatter keys. The first three are the Agent Skills spec subset, so
the skills still package for claude.ai and the Skills API; `disable-model-invocation` is the one exception, for
`setup`.

## `setup` is the only skill hidden from model invocation

Chosen over hiding every skill with side effects and letting the agent call them only by name. `setup` is a
run-once configurator the user enters deliberately. Hiding any other skill drops its description from the
agent's context, and the agent then runs the raw `git`/`gh`/`glab` command instead of the governed workflow, so
side effects are gated by permission rules instead.

## Bundled scripts are invoked directly, without a `bash` prefix or quotes

Chosen over calling a script as `bash <path>` or with a quoted path. The `allowed-tools` pre-approval rule
matches the literal command, so either form stops it matching.

## The root `plugin.json` keeps a `skills` array

Chosen over dropping the root aggregate, since the skills.sh CLI discovers skills by scanning for `SKILL.md`
and ignores manifest skill arrays. The aggregate stays as the repo-wide declared inventory for tooling that
reads it.

## Release tags are `<bucket>@X.Y.Z` with no `v` prefix

Chosen over `<bucket>/vX.Y.Z` and other `v`-prefixed scoped forms. `<pkg>@<semver>` is the convention
changesets, Lerna, and Nx use for per-package releases in a monorepo, and it is what the plugin ecosystem reads.

## No repo-wide `vX.Y.Z` tag

Chosen over tagging the whole repo alongside the bucket tags. The repo ships three independently versioned
plugins, so there is no single number such a tag could carry.

## Tags are created with `git tag -a`, not `claude plugin tag`

Chosen over `claude plugin tag`, which only emits `<bucket>--vX.Y.Z` and reads as a prerelease suffix rather
than a scope. That command also checked manifest and marketplace agreement, which is why that check is now done
by hand.

## Version bumps land through a PR before the tag

Chosen over bumping `plugin.json` in a direct commit or after tagging. The version must be on the tagged commit,
and `main` takes no direct commits.

## Remote tags are fetched before picking a version

Chosen over trusting the local tag list, which can be stale and produce a number that is already taken.
