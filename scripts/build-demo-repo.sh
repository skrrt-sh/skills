#!/usr/bin/env bash
set -euo pipefail

# Build the screen-recording demo repository.
#
# The tutorial shows /commit splitting a dirty worktree, so the four pending
# changes have to read as unrelated on sight — a viewer cannot pause and study
# the diff. Committed history uses the same gitmoji conventional format the
# skill produces, so the "after" state looks continuous with the "before".
#
# Safe to re-run between takes. By default it carries .agents/ship.md across so
# /setup stays a one-time step; pass --fresh when /setup is itself on camera and
# each take has to start unconfigured.
#
# Usage: build-demo-repo.sh [--fresh] <destination-dir>

dest=''
fresh=0

while [[ "$#" -gt 0 ]]; do
  case "${1}" in
    --fresh)
      fresh=1
      shift
      ;;
    *)
      dest="${1}"
      shift
      ;;
  esac
done

[[ -n "${dest}" ]] || {
  printf 'usage: build-demo-repo.sh [--fresh] <destination-dir>\n' >&2
  exit 1
}

marker='.skrrt-demo'
saved_policy=''

# Only ever delete a directory this script created. Anything else is the
# user's, and a wrong path here costs them real work.
if [[ -e "${dest}" ]]; then
  if [[ ! -f "${dest}/${marker}" ]]; then
    printf 'refusing to rebuild %s: not a demo repo (no %s marker)\n' "${dest}" "${marker}" >&2
    exit 1
  fi
  if [[ "${fresh}" -eq 0 && -f "${dest}/.agents/ship.md" ]]; then
    saved_policy="$(mktemp)"
    cp "${dest}/.agents/ship.md" "${saved_policy}"
  fi
  rm -rf "${dest}"
fi

mkdir -p "${dest}"
dest="$(cd "${dest}" && pwd)"

git init -q "${dest}"
git -C "${dest}" config user.email demo@skrrt.test
git -C "${dest}" config user.name 'Demo Author'
git -C "${dest}" config commit.gpgsign false
printf 'built by scripts/build-demo-repo.sh\n' > "${dest}/${marker}"
printf '%s\n' "${marker}" > "${dest}/.gitignore"

mkdir -p "${dest}/src"

# --- committed history -----------------------------------------------------

cat > "${dest}/package.json" <<'FILE'
{
  "name": "taskflow",
  "version": "0.3.0",
  "type": "module",
  "main": "src/index.ts"
}
FILE

cat > "${dest}/src/config.ts" <<'FILE'
export const config = {
  port: Number(process.env.PORT ?? 3000),
  pageSize: Number(process.env.PAGE_SIZE ?? 20),
}
FILE

# Pre-existing project context, so /setup is filmed inserting its block into a
# real instruction file rather than creating one. Makes "content outside the
# markers survives" visible on screen instead of asserted.
cat > "${dest}/CLAUDE.md" <<'FILE'
## Project

Taskflow is a small task API. Source lives in `src/`, entry point `src/index.ts`.

Keep modules single-purpose: tasks, pagination, and config stay separate.
FILE

git -C "${dest}" add -A
git -C "${dest}" commit -qm 'chore: :tada: scaffold the taskflow project'

cat > "${dest}/src/tasks.ts" <<'FILE'
export type Task = {
  id: string
  title: string
  done: boolean
}

const tasks: Task[] = []

export function createTask(title: string): Task {
  const task = { id: String(tasks.length + 1), title, done: false }
  tasks.push(task)
  return task
}

export function listTasks(): Task[] {
  return tasks
}
FILE

cat > "${dest}/src/index.ts" <<'FILE'
export { createTask, listTasks } from './tasks.ts'
export { config } from './config.ts'
FILE

git -C "${dest}" add -A
git -C "${dest}" commit -qm 'feat(tasks): :sparkles: add task creation and listing'

cat > "${dest}/src/pagination.ts" <<'FILE'
export function pageCount(total: number, limit: number): number {
  return Math.ceil(total / limit)
}

export function slice<T>(items: T[], page: number, limit: number): T[] {
  const start = (page - 1) * limit
  return items.slice(start, start + limit)
}
FILE

git -C "${dest}" add -A
git -C "${dest}" commit -qm 'feat(api): :sparkles: paginate the task list endpoint'

cat > "${dest}/README.md" <<'FILE'
# Taskflow

A small task API.

## Usage

```bash
npm start
```

The server listens on port 3000.

## Endpoints

- `POST /tasks` — create a task
- `GET /tasks` — list tasks, paginated
FILE

git -C "${dest}" add -A
git -C "${dest}" commit -qm 'docs(readme): :memo: document the task endpoints'

# --- the dirty worktree: four unrelated concerns ---------------------------

# 1. feature, spanning two files so the split has to group rather than
#    just map one file to one commit
cat > "${dest}/src/tasks.ts" <<'FILE'
export type Task = {
  id: string
  title: string
  done: boolean
  archived: boolean
}

const tasks: Task[] = []

export function createTask(title: string): Task {
  const task = {
    id: String(tasks.length + 1),
    title,
    done: false,
    archived: false,
  }
  tasks.push(task)
  return task
}

export function listTasks(): Task[] {
  return tasks.filter((task) => !task.archived)
}

export function archiveTask(id: string): Task | undefined {
  const task = tasks.find((candidate) => candidate.id === id)
  if (task) task.archived = true
  return task
}
FILE

cat > "${dest}/src/index.ts" <<'FILE'
export { createTask, listTasks, archiveTask } from './tasks.ts'
export { config } from './config.ts'
FILE

# 2. bug fix in an unrelated module — a dropped final page
cat > "${dest}/src/pagination.ts" <<'FILE'
export function pageCount(total: number, limit: number): number {
  return Math.floor(total / limit)
}

export function slice<T>(items: T[], page: number, limit: number): T[] {
  const start = (page - 1) * limit
  return items.slice(start, start + limit)
}
FILE

# 3. docs correction, unrelated to both — the documented port was wrong
cat > "${dest}/README.md" <<'FILE'
# Taskflow

A small task API.

## Requirements

- Node.js 22 or newer

## Usage

```bash
npm start
```

The server listens on port 8080.

## Endpoints

- `POST /tasks` — create a task
- `GET /tasks` — list tasks, paginated
FILE

# 4. pure formatting, no behaviour change
cat > "${dest}/src/config.ts" <<'FILE'
export const config = {
  port:     Number(process.env.PORT ?? 3000),
  pageSize: Number(process.env.PAGE_SIZE ?? 20),
}
FILE

if [[ -n "${saved_policy}" ]]; then
  mkdir -p "${dest}/.agents"
  cp "${saved_policy}" "${dest}/.agents/ship.md"
  rm -f "${saved_policy}"
fi

printf 'demo repo ready: %s\n\n' "${dest}"
git -C "${dest}" -c color.ui=always status --short
printf '\n'
if [[ -f "${dest}/.agents/ship.md" ]]; then
  printf 'policy: .agents/ship.md carried over\n'
elif [[ "${fresh}" -eq 1 ]]; then
  printf 'policy: cleared — /setup runs on camera\n'
else
  printf 'policy: missing — run /setup in %s before recording\n' "${dest}"
fi
