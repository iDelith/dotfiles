# Dotfiles — Agent Instructions

## Purpose

This repository is a reproducible, cross-platform dotfiles and machine-bootstrap system.

Primary platforms:

- Arch Linux
- macOS

Prioritize:

- Simplicity
- Safety
- Idempotency
- Maintainability
- Clear separation of concerns

Detailed architecture and implementation information belongs in the project documentation.

---

## Before Starting Work

Before starting or resuming any task:

1. Read `orchestration/STATE.md`.
2. Read `docs/IMPLEMENTATION.md`.
3. Read `docs/ARCHITECTURE.md` when architectural context is relevant.
4. Read `docs/HISTORY.md` when historical context is relevant.

Use the `Resume Point` in `orchestration/STATE.md` when taking over existing work.

Do not assume previous conversation or agent context is available.

`orchestration/STATE.md` is the authoritative source for the current active task and resume point.

---

## Development Workflow

Before implementing a meaningful feature or change:

1. Briefly describe the implementation plan.
2. Describe the expected behavior.
3. Identify affected files or modules when relevant.
4. Identify important risks or architectural implications when applicable.
5. Wait for explicit user approval.
6. Implement the approved plan.
7. Test the implementation.
8. Report the result and relevant findings.
9. Ask for explicit approval before committing.

Never commit automatically.

Implementation approval and commit approval are separate gates.

If implementation requires materially changing the approved plan or expanding its scope, stop and ask the user before proceeding.

### Git and commit workflow

- Keep commits atomic: one logical change or milestone per commit.
- Stage files explicitly and never include unrelated worktree changes.
- Work on feature branches rather than committing directly to `main`.
- Push the active branch with `git push -u origin HEAD`; never hardcode `main` in push commands.
- Merge changes into `main` through reviewed pull requests.
- Do not rewrite remote history unless explicitly approved.

---

## Non-Negotiable Rules

- Keep `install.sh` as the orchestration entry point.
- Keep implementation logic modular under `scripts/`.
- Keep package definitions declarative under `packages/`.
- Treat `home/` as a mirror of `$HOME`.
- Keep the installer idempotent.
- Never silently overwrite user configuration.
- Back up existing configuration before replacement.
- Never store credentials.
- Test destructive filesystem operations in a temporary environment first.
- Do not manipulate `.git/` as part of installation.
- Do not introduce unnecessary dependencies or speculative abstractions.
- Preserve established architectural decisions unless there is a concrete reason to change them.

Detailed architectural rules belong in `docs/ARCHITECTURE.md`.

---

## Documentation

Documentation is part of the implementation.

When a meaningful feature is completed:

1. Update `docs/IMPLEMENTATION.md`.
2. Append the relevant milestone to `docs/HISTORY.md`.
3. Update `docs/ARCHITECTURE.md` if the architecture changed.
4. Update `orchestration/STATE.md`.
5. Update `AGENTS.md` only if a permanent project or agent rule changed.

Keep `AGENTS.md` stable and concise.

Do not use `AGENTS.md` as an implementation diary.

Keep `orchestration/STATE.md` focused on ephemeral coordination state.

---

## Project Resources

| Resource | Purpose |
|---|---|
| `docs/ARCHITECTURE.md` | System architecture and design decisions |
| `docs/IMPLEMENTATION.md` | Current implementation status and milestones |
| `docs/HISTORY.md` | Historical decisions and project evolution |
| `orchestration/STATE.md` | Active task, ownership, status, and resume point |

Use these resources instead of duplicating detailed information in `AGENTS.md`.
