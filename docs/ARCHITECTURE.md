# Architecture

## 1. System Overview

This repository is a cross-platform dotfiles and machine-bootstrap system.

The installer is intentionally modular:

```text
install.sh
    │
    ├── logging.sh
    ├── system.sh
    ├── packages.sh
    ├── links.sh
    ├── git.sh
    ├── selection.sh
    └── ssh.sh
```

`install.sh` orchestrates the workflow. Individual modules own implementation details.

Primary supported platforms:

- Arch Linux
- macOS

The architecture separates:

```text
OS family
Distribution
Architecture
```

Example:

```text
OS_FAMILY=linux
DISTRO=arch
ARCH=x86_64
```

This allows Linux-wide behavior to remain independent from distribution-specific behavior.

---

## 2. Repository Structure

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
│   ├── .config/
│   │   ├── starship.toml
│   │   └── zsh/
│   │       ├── aliases/
│   │       ├── completion/
│   │       ├── environment/
│   │       ├── functions/
│   │       ├── history/
│   │       ├── integrations/
│   │       └── shell-options/
│   └── .zshrc
├── packages/
│   ├── common.txt
│   ├── arch.txt
│   ├── macos.txt
│   └── zsh-integrations/
│       └── starship.txt
├── scripts/
│   ├── git.sh
│   ├── ssh.sh
│   ├── selection.sh
│   ├── logging.sh
│   ├── system.sh
│   ├── packages.sh
│   ├── links.sh
│   └── install.sh
```

### `home/`

A filesystem-like representation of `$HOME`.

```text
home/.zshrc
    → ~/.zshrc

home/.config/nvim/
    → ~/.config/nvim/
```

The installer should recursively map `home/` into `$HOME` using symbolic links.

### `packages/`

Declarative package inventories.

```text
packages/
├── common.txt
├── arch.txt
├── macos.txt
└── zsh-integrations/
    └── starship.txt
```

These files describe desired packages, not installation commands.

### `scripts/`

Implementation modules with cohesive responsibilities.

### Shell configuration modules

The shell configuration is split into concern-based directories under
`home/.config/zsh/`. Each directory may contain multiple `.zsh` modules, and
`home/.zshrc` loads the directories in a predictable order. Starship is an
integration/prompt layer and is initialized only when its executable is
available.

### Installer selection state

Interactive selections are runtime machine state, not repository
configuration. They are stored beneath `$XDG_STATE_HOME`:

```text
$XDG_STATE_HOME/dotfiles/selections/
└── zsh-integrations/
    └── enabled.zsh
```

This keeps generated selections outside the repository and outside the
managed `~/.config` symlink. Each future installer section can own a separate
subdirectory under `selections/`.

Git identity state is stored separately at:

```text
~/.local/state/dotfiles/git/identity.gitconfig
```

The managed `.gitconfig` includes this file but does not contain a personal
name or email address. Remote preflight verifies read access; write access
still depends on the user's configured GitHub authentication.

SSH setup is an explicit standalone workflow in `scripts/ssh.sh`. It may
generate a local Ed25519 key when the user requests it, optionally register
the public key through an authenticated GitHub CLI, verify SSH access, and
switch the repository remote after confirmation. It never overwrites private
keys or disables host-key verification.

### `install.sh`

Main orchestration entry point.

### `backup/`

Historical/reference configuration, when present. It is not the runtime backup destination.

### `docs/`

Project documentation.

### `orchestration/`

Current work coordination and state.

---

## 3. Module Responsibilities

### `scripts/logging.sh`

Owns all installer output.

API:

```text
log_info()
log_success()
log_skip()
log_error()
log_section()
```

Semantics:

```text
[INFO]  information, context, or progress
[ OK ]  operation completed successfully
[SKIP]  desired state already exists
[ERROR] operation failed
```

`log_section()` provides visual separation between major phases.

---

### `scripts/system.sh`

Owns system/environment detection and validation.

Responsibilities:

```text
detect_system()
detect_architecture()
validate_environment()
validate_sudo()
```

It determines:

```text
OS_FAMILY
DISTRO
ARCH
```

It does not install packages or deploy configuration.

---

### `scripts/packages.sh`

Owns package installation.

Architecture:

```text
install_packages()
    │
    ├── linux
    │     └── DISTRO
    │           └── arch → pacman
    │
    └── macos
          └── Homebrew
```

Package inventories remain in `packages/`.

---

### `scripts/git.sh`

Owns machine-specific Git identity state and remote read-access validation.
It does not write personal identity values into the repository-managed
`.gitconfig`.

---

### `scripts/selection.sh`

Owns interactive installer selections. It provides the `ZSH Integrations`
menu, supports keyboard toggling, and persists selected state outside the
repository. Noninteractive operation enables all currently defined and future
integration manifests.

---

### `scripts/ssh.sh`

Owns explicit GitHub SSH setup. It detects or creates an Ed25519 key, uses
`ssh-agent`, supports authenticated `gh` registration or manual registration,
verifies GitHub SSH access, and changes the repository remote only after
confirmation.

---

### `scripts/links.sh`

Owns symbolic-link management.

Its source of truth is:

```text
$DOTFILES_DIR/home/
```

Its deployment target is:

```text
$HOME/
```

It must handle:

- Missing destinations
- Correct existing symlinks
- Incorrect symlinks
- Existing files
- Existing directories
- Backups
- Idempotent re-runs

---

## 4. OS and Distribution Model

Broad platform behavior should use:

```bash
if [[ "$OS_FAMILY" == "linux" ]]; then
    ...
fi
```

Distribution-specific behavior should use:

```bash
case "$DISTRO" in
    arch)
        ...
        ;;
    ubuntu)
        ...
        ;;
esac
```

Do not scatter distribution names through unrelated modules.

A future Linux distribution should primarily require adding its detection and package-manager implementation rather than rewriting the entire installer.

---

## 5. Package Architecture

Package files are declarative.

Example:

```text
git
tree
```

The package implementation determines how those packages are installed.

### Arch

Use `pacman`.

Check installed packages with:

```bash
pacman -Q "$package"
```

Install missing packages with:

```bash
sudo pacman -S --needed --noconfirm "$package"
```

### macOS

Use Homebrew.

The current design expects Homebrew to already be installed.

Homebrew bootstrapping is a separate future concern.

---

## 6. Privilege Architecture

Linux privilege validation uses:

```bash
sudo -v
```

The installer never reads or stores the sudo password.

Privilege validation is based on:

```text
OS_FAMILY=linux
```

rather than a specific distribution.

macOS does not automatically request administrator privileges.

---

## 7. Configuration / Symlink Architecture

The `home/` directory is treated as a miniature `$HOME`.

For every repository path:

```text
$DOTFILES_DIR/home/<path>
```

the desired destination is:

```text
$HOME/<path>
```

Example:

```text
home/.config/nvim/
```

becomes:

```text
~/.config/nvim/
```

The implementation should not hardcode individual configuration files.

### Desired behavior

| Destination state | Action |
|---|---|
| Missing | Create symlink |
| Correct symlink | Skip |
| Incorrect symlink | Replace |
| Real file | Backup, then replace |
| Real directory | Backup, then replace |

Runtime backups belong next to the original configuration:

```text
~/.zshrc.backup-YYYYMMDD-HHMMSS
```

They do not belong in the repository's `backup/` directory.

---

## 8. Idempotency

All installation phases should converge toward the desired state.

Repeated execution should not unnecessarily reinstall packages or recreate correct symlinks.

Examples:

```text
Already installed
    → SKIP

Already linked correctly
    → SKIP

Missing
    → CREATE / INSTALL

Existing user configuration
    → BACKUP + REPLACE
```

---

## 9. Safety

The installer must never silently destroy user configuration.

Filesystem-destructive behavior must first be tested in a temporary environment.

The real `$HOME` should only be touched after the behavior has been validated.

The installer must never:

- Store credentials
- Delete user configuration without protection
- Manipulate `.git/` as part of deployment
- Hardcode the user's home directory
- Assume the machine is clean

---

## 10. Extension Guidelines

When adding functionality:

1. Determine which existing module owns the responsibility.
2. Extend that module if appropriate.
3. Create a new module only when a new cohesive responsibility exists.
4. Keep `install.sh` as orchestration.
5. Keep platform-specific implementation behind platform abstractions.
6. Update documentation when the architecture changes.

Avoid speculative abstractions and unnecessary dependencies.

The project intentionally uses native shell functionality rather than GNU Stow.

---

## 11. Architecture Decision Principle

Prefer designs that are:

1. Simple
2. Safe
3. Reproducible
4. Idempotent
5. Understandable
6. Easy for another agent or human to continue

Architecture should evolve when there is a concrete requirement, not merely for theoretical extensibility.
