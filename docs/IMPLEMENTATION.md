# Implementation Status

## Current Milestone

**Milestone:** Installer Foundation and Shell Bootstrap

**Status:** Implemented

The installer foundation, package-management layers, symlink-management
phase, modular Zsh configuration, Git setup, and SSH setup workflow are
implemented. The repository is currently synchronized with `origin/main`.

---

## Completed

### Installer Foundation

- Bash-based `install.sh` created.
- Modular architecture established.
- `install.sh` acts as the orchestration entry point.
- Modules are loaded from `scripts/`.

### System Detection

Implemented:

```text
OS_FAMILY
DISTRO
ARCH
```

Current Arch environment is expected to resolve approximately to:

```text
OS_FAMILY=linux
DISTRO=arch
ARCH=x86_64
```

macOS is modeled as:

```text
OS_FAMILY=macos
DISTRO=macos
```

### Environment Validation

The installer validates:

- Git repository presence
- Home directory
- Dotfiles directory

### Linux Privilege Validation

Linux systems validate sudo credentials using:

```bash
sudo -v
```

This is controlled by `OS_FAMILY`, not by a list of distributions.

### Package Installation

Implemented package lists:

```text
packages/common.txt
packages/arch.txt
packages/macos.txt
packages/zsh-integrations/starship.txt
```

Arch uses `pacman`.

Already-installed packages are detected and reported as:

```text
[SKIP] Package already installed: <package>
```

macOS uses Homebrew.

The current macOS implementation expects Homebrew to already be installed.

### Logging

Implemented:

```text
log_info()
log_success()
log_skip()
log_error()
log_section()
```

Logging semantics are:

```text
[INFO]  context/progress
[ OK ]  successful operation
[SKIP]  already in desired state
[ERROR] failure
```

Section headers are used for major installation phases.

---

## Current Repository Model

The desired repository structure is:

```text
dotfiles/
├── AGENTS.md
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── HISTORY.md
│   └── IMPLEMENTATION.md
├── orchestration/
│   └── STATE.md
├── home/
├── packages/
├── scripts/
│   ├── links.sh
│   ├── logging.sh
│   ├── packages.sh
│   ├── git.sh
│   ├── selection.sh
│   ├── ssh.sh
│   └── system.sh
└── install.sh
```

---

## Current Symlink Implementation

Created:

```text
scripts/links.sh
```

Implemented:

```text
backup_file()
link_file()
```

### `backup_file()`

Creates timestamped backups next to the original user configuration.

Example:

```text
~/.zshrc
→ ~/.zshrc.backup-YYYYMMDD-HHMMSS
```

The repository's `backup/` directory is not used for runtime backups.

### `link_file()`

Currently handles:

1. Missing destination → create symlink.
2. Correct symlink → skip.
3. Incorrect symlink → remove and replace.
4. Existing real path → invoke `backup_file()` before replacement.

The primitive operations and recursive deployment have been validated in a
temporary test environment for the documented filesystem cases.

### `link_home()`

Recursively deploys the repository's `home/` tree into the target home
directory. Directories are created or traversed in place and every file (and
symlink) is linked at its matching relative path. This means, for example,
`home/.zshrc` always maps to `~/.zshrc` with a target of
`$DOTFILES_DIR/home/.zshrc`.

The function creates the destination home directory and required parent
directories, while delegating file and symlink replacement behavior to
`link_file()`. Existing real directories are preserved so their contents can
be reconciled recursively instead of being replaced by a link to the entire
repository directory.

---

## Current Testing

A temporary test environment was created conceptually under:

```text
/tmp/dotfiles-link-test/
```

The real `$HOME` must not be used for destructive symlink testing until the implementation has been validated.

Testing should cover:

1. Missing destination
2. Correct existing symlink
3. Incorrect existing symlink
4. Existing real file
5. Existing backup
6. Existing real directory
7. Nested configuration paths

---

## Symlink Status

Recursive deployment and installer integration are implemented and tested in a
temporary environment. The real `$HOME` has not been used for destructive
testing.

The symlink-management milestone is complete:

```text
1. Recursive deployment is integrated into `install.sh`.
2. Existing files and directories are backed up before replacement.
3. Repeated runs converge without recreating correct links.
```

---

## Standalone Shell Configuration

`home/.zshrc` now provides a native Zsh baseline without requiring external
frameworks. It includes:

- Environment defaults for editor and XDG paths
- User-local `PATH` entries, including `~/.local/bin`, `~/bin`, and Hermes
  user-local directories when present
- History settings
- Native Zsh options and completion
- Portable aliases with optional-command fallbacks
- Git aliases
- A small `mkcd` helper

Oh My Zsh, Powerlevel10k, and `zsh-z` are intentionally not loaded by the
baseline configuration. Starship is loaded as an optional prompt integration
when its executable is available.

`home/.zprofile` loads the shared environment module for login shells, while
`.zshrc` continues to load the complete interactive configuration. The
configuration was validated in an isolated temporary home with Zsh.

Shell modules are organized into concern-based directories under
`home/.config/zsh/`. Each directory can contain multiple `.zsh` files and is
loaded by `home/.zshrc` in a predictable order:

```text
environment/
history/
shell-options/
completion/
aliases/
functions/
integrations/
```

The installer exposes a `ZSH Integrations` selection phase. Interactive runs
allow integrations to be toggled with the keyboard. `--non-interactive` runs
enable every integration package currently defined in
`packages/zsh-integrations/`, including integrations added in the future.

Selections are persisted outside the repository under:

```text
$XDG_STATE_HOME/dotfiles/selections/zsh-integrations/enabled.zsh
```

The default is `~/.local/state/dotfiles/`. This prevents generated
machine-specific state from being written through the repository's managed
`~/.config` symlink.

Git identity is stored separately in
`~/.local/state/dotfiles/git/identity.gitconfig` and included by the managed
`.gitconfig`. The installer accepts `--git-name` and `--git-email`, while
noninteractive mode does not guess missing identity values. Git remote
preflight verifies read access without attempting a push.

SSH setup is available as a standalone command:

```bash
./scripts/ssh.sh
```

It detects or generates an Ed25519 key, starts or uses `ssh-agent`, optionally
registers the public key through an authenticated `gh` CLI, verifies GitHub
SSH authentication, and changes `origin` to its GitHub SSH URL after
confirmation. Existing private keys are never overwritten.

---

## Installer Workflow

The main installer currently uses these phases:

```text
System Detection
ZSH Integrations
Privilege Check
Package installation
Symbolic Link Management
Git Setup
```

`install.sh` invokes module functions without embedding their implementation
details directly in the orchestrator. Git identity and remote read-access
validation run last so a fresh machine can complete local configuration before
any GitHub interaction is attempted.

The package installation phase reports installed, already-installed, and
resolved package counts. It then lists only the applications installed during
the current run, providing a concise way to identify missing or skipped
applications without reviewing the full command log.

The intended mapping is:

```text
$DOTFILES_DIR/home/
        ↓
      $HOME/
```

---

## Definition of Done for Symlink Management

The feature is considered complete only when:

- All required filesystem cases have been tested.
- Existing user files are protected.
- Existing directories are protected.
- Correct links are skipped.
- Incorrect links are handled explicitly.
- The operation is idempotent.
- Recursive deployment works.
- The real repository can be deployed safely.
- `install.sh` integration is complete.
- Documentation is updated.
- The user has reviewed the implementation.
- The user explicitly approves the Git commit.

---

## Future Milestones

After symlink management is complete, likely milestones include:

1. Additional interactive selection sections.
2. Explicit SSH setup refinements and broader authentication testing.
3. Additional package inventories.
4. Additional Linux distributions.
5. Application-specific setup where justified.
6. Broader end-to-end testing on a fresh machine.

These are planning items, not current implementation tasks.

---

## Documentation Maintenance

When the current milestone changes:

- Update this file to reflect the new current state.
- Append the completed milestone to `docs/HISTORY.md`.
- Update `docs/ARCHITECTURE.md` if architectural behavior changed.
- Update `orchestration/STATE.md`.
- Update `AGENTS.md` only when permanent rules change.
