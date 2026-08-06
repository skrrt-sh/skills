#!/usr/bin/env python3
"""Grade behavior-eval runs from repository state.

The eval assertions split into two kinds. Most are objective facts about the
resulting repository — which files were committed, whether a message matches the
required shape, whether an untouched file stayed untouched. Those are checked
here, because a script is faster and more consistent than reading diffs by eye,
and it reruns identically on the next iteration.

The remainder are process assertions ("the staged diff is reviewed before
committing"). They live in the run's summary.md rather than in repository state,
so they are emitted with passed=None for a human or grading agent to resolve.

Usage: grade-eval-runs.py <workspace>/iteration-N
"""
import json
import re
import subprocess
import sys
from pathlib import Path

SUBJECT = re.compile(r"^(feat|fix|chore|docs|refactor|test|ci|build|perf|style|revert)(\([^)]+\))?: :[a-z0-9_+-]+: .+")
COAUTHOR = "Co-Authored-By: Skrrt Bot <bot@skrrt.sh>"


def git(repo, *args):
    r = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True)
    return r.stdout.strip()


def commits_since_fixture(repo):
    """Commits the run created, i.e. everything after the seeded fixture history."""
    log = git(repo, "log", "--format=%H%x1f%B%x1e").split("\x1e")
    out = []
    for entry in log:
        if not entry.strip():
            continue
        sha, _, body = entry.strip().partition("\x1f")
        if body.startswith("chore: :tada: initial fixture") or body.startswith("feat(parser): :sparkles: merge PR #42"):
            break
        out.append((sha, body.strip()))
    return out


def check(text, passed, evidence):
    return {"text": text, "passed": passed, "evidence": evidence}


def grade_commit(repo, name):
    res = []
    made = commits_since_fixture(repo)
    branch = git(repo, "branch", "--show-current")
    status = git(repo, "status", "--short")

    for sha, body in made:
        subject = body.splitlines()[0]
        res.append(check(
            f"Commit {sha[:7]} subject matches 'type(scope): :gitmoji: subject'",
            bool(SUBJECT.match(subject)), subject))
        lines = [ln for ln in body.splitlines()[1:] if ln.strip() and not ln.startswith("Co-Authored-By")]
        res.append(check(f"Commit {sha[:7]} has an explanatory body", len(lines) > 0,
                         f"{len(lines)} body line(s)"))
        res.append(check(f"Commit {sha[:7]} carries the configured co-author trailer",
                         COAUTHOR in body, COAUTHOR if COAUTHOR in body else "absent"))

    if name == "eval-0-focused-fix":
        readme_dirty = "README.md" in status
        res.append(check("The unrelated README draft remains uncommitted", readme_dirty,
                         f"git status --short:\n{status or '(clean)'}"))
        touched = git(repo, "show", "--name-only", "--format=", "HEAD").split()
        res.append(check("The commit excludes README.md", "README.md" not in touched,
                         f"files in HEAD: {touched}"))
        res.append(check("Exactly one commit was created", len(made) == 1, f"{len(made)} commit(s)"))

    if name == "eval-1-protected-branch":
        res.append(check("Work moved off the protected branch", branch not in ("main", "master"),
                         f"current branch: {branch}"))
        res.append(check("Branch name follows <type>/<description>",
                         bool(re.match(r"^[a-z]+/[a-z0-9._-]+$", branch)), branch))
        main_head = git(repo, "log", "-1", "--format=%s", "main")
        res.append(check("No commit was created on main",
                         main_head.startswith("chore: :tada: initial fixture"), f"main HEAD: {main_head}"))
        res.append(check("The authentication change is committed somewhere", len(made) >= 1,
                         f"{len(made)} commit(s)"))

    if name == "eval-2-split-intents":
        res.append(check("The search work and CI cleanup are committed separately", len(made) == 2,
                         f"{len(made)} commit(s): {[b.splitlines()[0] for _, b in made]}"))
        filesets = [set(git(repo, "show", "--name-only", "--format=", sha).split()) for sha, _ in made]
        mixed = any({"src/search.js", ".github/workflows/ci.yml"} <= fs for fs in filesets)
        res.append(check("No single commit mixes the two intents", not mixed, f"file sets: {filesets}"))

    if name == "eval-3-merged-precedent":
        res.append(check("A fresh branch was created rather than reusing the merged branch",
                         branch not in ("main", "master", "feat/parser-rewrite"), f"current branch: {branch}"))
        all_branches = git(repo, "branch", "--list", "--format=%(refname:short)").split()
        res.append(check("The merged source branch is not resurrected",
                         "feat/parser-rewrite" not in all_branches, f"branches: {all_branches}"))
        # An issue reference is only invented if the prompt never named it. This scenario's
        # prompt names PR #42, so citing #42 is grounded, not fabricated.
        prompt = json.loads((repo.parent.parent / "eval_metadata.json").read_text())["prompt"]
        named = set(re.findall(r"#(\d+)", prompt))
        bodies = " ".join(b for _, b in made)
        cited = set(re.findall(r"(?:Closes|Fixes|Refs) #(\d+)", bodies))
        invented = cited - named
        res.append(check("No issue footer is invented",
                         not invented,
                         f"cited {sorted(cited) or 'none'}; prompt names {sorted(named) or 'none'}"))

    res.append(check("Staged and unstaged changes were inspected before staging", None, "see summary.md"))
    res.append(check("The staged diff was reviewed before committing", None, "see summary.md"))
    res.append(check("No test results are invented", None, "see summary.md"))
    return res


def frontmatter(path):
    t = path.read_text()
    if not t.startswith("---"):
        return {}, t
    _, _, rest = t.partition("---\n")
    fm, _, body = rest.partition("---\n")
    keys = {}
    for line in fm.splitlines():
        if ":" in line and not line.startswith(" "):
            k, _, v = line.partition(":")
            keys[k.strip()] = v.strip().strip('"')
    return keys, body


def grade_mdwriter(repo, name):
    res = []
    docs = sorted(p for p in (repo / "docs").rglob("*.md")) if (repo / "docs").exists() else []

    if name == "eval-0-greenfield":
        target = repo / "docs/local-postgres.md"
        res.append(check("docs/local-postgres.md is created", target.exists(), str(target)))
        res.append(check("Only that one document is created", len(docs) == 1,
                         f"docs/: {[str(p.relative_to(repo)) for p in docs]}"))
        if target.exists():
            fm, body = frontmatter(target)
            h1 = next((l[2:].strip() for l in body.splitlines() if l.startswith("# ")), "")
            res.append(check("The H1 matches the frontmatter title",
                             h1 == fm.get("title", "\x00"), f"title={fm.get('title')!r} h1={h1!r}"))
            res.append(check("No invented author or external reference in frontmatter",
                             "author" not in fm and "refs" not in fm, f"keys: {sorted(fm)}"))
            res.append(check("Contains a Mermaid diagram", "```mermaid" in body, "```mermaid present" if "```mermaid" in body else "absent"))
            # Fences alternate open/close; only the opening fence carries a language.
            opening = re.findall(r"^```(\w*)", body, re.M)[::2]
            res.append(check("Every code fence has a language", all(opening), f"opening fences: {opening}"))

    if name == "eval-1-local-convention":
        errors = repo / "docs/api/errors.md"
        new_docs = [p for p in docs if p.name not in ("errors.md", "pagination.md")]
        res.append(check("A new specification document is created", len(new_docs) == 1,
                         f"new: {[str(p.relative_to(repo)) for p in new_docs]}"))
        res.append(check("docs/api/errors.md is not edited",
                         git(repo, "status", "--short", "docs/api/errors.md") == "",
                         git(repo, "status", "--short") or "(clean)"))
        if new_docs:
            fm, _ = frontmatter(new_docs[0])
            res.append(check("Uses the local title/owner/last_reviewed vocabulary, not the skill defaults",
                             {"title", "owner", "last_reviewed"} <= set(fm), f"keys: {sorted(fm)}"))
            res.append(check("Does not impose the skill's default status/created/updated fields",
                             not ({"created", "updated", "status"} & set(fm)), f"keys: {sorted(fm)}"))

    if name == "eval-2-adr-update":
        adr = repo / "docs/adr/0012-cache.md"
        fm, body = frontmatter(adr)
        res.append(check("The ADR metadata vocabulary is preserved",
                         {"title", "status", "decision-date"} <= set(fm), f"keys: {sorted(fm)}"))
        res.append(check("No skill-default frontmatter fields are grafted on",
                         not ({"created", "updated", "version", "description"} & set(fm)), f"keys: {sorted(fm)}"))
        res.append(check("The established section structure is preserved",
                         all(h in body for h in ("## Context", "## Options considered", "## Decision", "## Consequences")),
                         [l for l in body.splitlines() if l.startswith("## ")]))
        res.append(check("The Redis decision is recorded", "Redis" in body.split("## Decision")[-1],
                         body.split("## Decision")[-1][:200]))
        res.append(check("No table of contents is introduced",
                         "table of contents" not in body.lower(), "absent" if "table of contents" not in body.lower() else "present"))
        res.append(check("The sibling ADR 0011 is untouched",
                         git(repo, "status", "--short", "docs/adr/0011-queue.md") == "",
                         git(repo, "status", "--short") or "(clean)"))

    if name == "eval-3-no-linter":
        target = repo / "docs/runbook.md"
        res.append(check("docs/runbook.md is created", target.exists(), str(target)))
        res.append(check("The run reports that validation could not run", None, "see summary.md"))
        res.append(check("The run does not claim the document is lint-clean", None, "see summary.md"))
        res.append(check("The run identifies how to make markdownlint available", None, "see summary.md"))

    return res


def main():
    root = Path(sys.argv[1])
    for eval_dir in sorted(p for p in root.iterdir() if p.is_dir() and p.name.startswith("eval-")):
        for cfg in ("with_skill", "old_skill"):
            run = eval_dir / cfg
            repo = run / "repo"
            if not repo.exists():
                continue
            grader = grade_commit if "ship-workspace" in str(root) else grade_mdwriter
            expectations = grader(repo, eval_dir.name)
            decided = [e for e in expectations if e["passed"] is not None]
            passed = sum(1 for e in decided if e["passed"])
            (run / "grading.json").write_text(json.dumps({
                "eval_name": eval_dir.name,
                "configuration": cfg,
                "expectations": expectations,
                "summary": {
                    "passed": passed,
                    "failed": len(decided) - passed,
                    "total": len(decided),
                    "pass_rate": round(passed / len(decided), 4) if decided else 0.0,
                },
            }, indent=2) + "\n")
            print(f"{eval_dir.name:28s} {cfg:10s} {sum(1 for e in decided if e['passed'])}/{len(decided)}")


if __name__ == "__main__":
    main()
