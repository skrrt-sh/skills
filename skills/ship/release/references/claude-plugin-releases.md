# Claude Code plugin releases

Use this branch only when the repository contains `.claude-plugin/plugin.json`.

## Single-plugin repository

Before tagging, make the manifest version match the release through the configured commit and PR
workflow. After the matching `vX.Y.Z` tag is published, run `claude plugin tag --dry-run` and then
`claude plugin tag --push -m <message>`. The resulting `<plugin-name>--vX.Y.Z` tag serves Claude
tooling; `vX.Y.Z` remains the repository release tag.

## Multi-plugin repository

When marketplace entries point to independently versioned plugin directories, do not create one
repo-wide version. For the selected plugin:

1. Match its manifest and marketplace versions through a PR.
2. Find the previous `<plugin-name>--v*` tag.
3. Limit release history to the plugin directory.
4. Run `claude plugin tag --dry-run <plugin-directory>` before `--push`.
5. Create one forge release for the plugin tag.

Treat a plugin rename as a breaking change. Bump the major version and add the marketplace rename
mapping before release so existing installations migrate.
