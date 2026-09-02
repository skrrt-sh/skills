# Claude Code plugin releases

Use this branch only when the repository contains `.claude-plugin/plugin.json`.

Repository policy wins on tag format. When `.agents/ship.md` defines a tag shape, follow it and
ignore the defaults below — they describe what `claude plugin tag` produces for a repository that
has not made its own choice.

## Single-plugin repository

Before tagging, make the manifest version match the release through the configured commit and PR
workflow. After the matching `vX.Y.Z` tag is published, run `claude plugin tag --dry-run` and then
`claude plugin tag --push -m <message>`. The resulting `<plugin-name>--vX.Y.Z` tag serves Claude
tooling; `vX.Y.Z` remains the repository release tag.

## Multi-plugin repository

When marketplace entries point to independently versioned plugin directories, do not create one
repo-wide version. For the selected plugin:

1. Match its manifest and marketplace versions through a PR.
2. Find the previous tag in that plugin's namespace.
3. Limit release history to the plugin directory.
4. Create the tag in the format the repository requires, then push it.
5. Create one forge release for the plugin tag.

`claude plugin tag` emits only `<plugin-name>--vX.Y.Z` and has no format option. Use it — with
`--dry-run` first — when that is the repository's format. When the repository defines another
shape, tag with `git tag -a` instead and take over the check the command performed: the plugin's
`plugin.json` version and its marketplace entry must agree with the tag before it is pushed.

Treat a plugin rename as a breaking change. Bump the major version and add the marketplace rename
mapping before release so existing installations migrate.
