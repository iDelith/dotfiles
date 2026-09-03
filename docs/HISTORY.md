# Project History

This document is the chronological record of meaningful implementation milestones, architectural decisions, and important changes to the dotfiles project.

History is append-only. If an earlier decision is later changed, preserve the original entry and add a new entry explaining the change and its rationale.

---

## 2026-08-20 — Project Bootstrap

### Initial Goal

Established the goal of building a professional, maintainable `install.sh` for a personal dotfiles repository.

The installer is intended to support multiple machines and operating systems, primarily:

- Arch Linux
- macOS

The design should avoid becoming a monolithic shell script.

### Repository Organization

Established the use of a repository-level `home/` directory as a miniature representation of `$HOME`.

Example:

```text
home/.zshrc
    → ~/.zshrc

home/.config/nvim/
    → ~/.config/nvim/
```

The repository also retains a separate `backup/` directory containing the user's previous configuration.

The repository's `backup/` directory is reference/legacy material and is not the destination for runtime backups created by the installer.

### Native Symlink Management

Decided not to use GNU Stow.

The project will implement symbolic-link management using native shell/Linux/macOS filesystem commands.

---

## 2026-08-21 — Installer Foundation

### Modular Shell Architecture

Established that `install.sh` should remain an orchestrator rather than contain all implementation details.

Initial module responsibilities:

```text
scripts/
├── logging.sh
├── system.sh
└── packages.sh
```

The intended principle is:

> One module = one cohesive responsibility.

Avoid both monolithic scripts and excessive fragmentation.

### Environment Detection

Implemented system and environment validation.

The installer reports:

- Operating system
- Architecture
- Home directory
- Dotfiles directory

### OS Family / Distribution Separation

Refactored the platform model to distinguish:

```text
OS_FAMILY
DISTRO
ARCH
```

Example for the current Arch machine:

```text
OS_FAMILY=linux
DISTRO=arch
ARCH=x86_64
```

Example for macOS:

```text
OS_FAMILY=macos
DISTRO=macos
ARCH=arm64
```

This was deliberately chosen so broad Linux behavior can use:

```bash
[[ "$OS_FAMILY" == "linux" ]]
```

instead of maintaining a growing list of Linux distributions.

Distribution-specific behavior belongs under `DISTRO`.

### Sudo Validation

Established that `sudo` should be treated as a general Linux privilege mechanism rather than an Arch-specific feature.

Linux privilege validation uses:

```bash
sudo -v
```

The installer does not read, store, or manipulate the user's sudo password.

macOS should not request sudo merely because the installer is running.

---

## 2026-08-21 — Package Installation

### Declarative Package Lists

Established the package directory:

```text
packages/
├── common.txt
├── arch.txt
└── macos.txt
```

Package files describe what should be installed, not how it should be installed.

Current common packages include:

```text
git
tree
```

### Arch Linux Package Support

Implemented Arch package installation using `pacman`.

The installer checks whether packages are already installed using:

```bash
pacman -Q
```

Already-installed packages are reported as:

```text
[SKIP] Package already installed: <package>
```

Missing packages are installed using:

```bash
sudo pacman -S --needed --noconfirm
```

### macOS Package Support

Added the macOS/Homebrew package path.

The current design expects Homebrew to already be installed on macOS.

Homebrew itself is not automatically bootstrapped by the package layer at this stage.

---

## 2026-08-21 — Logging Improvements

### Logging Semantics

Established a consistent logging API:

```text
log_info()
log_success()
log_skip()
log_error()
log_section()
```

The semantics are:

```text
[INFO]  → information, context, or progress
[ OK ]  → operation completed successfully
[SKIP]  → desired state already exists
[ERROR] → operation failed
```

An important design correction was made:

Detected system state should use `log_info`, not `log_success`.

For example:

```bash
log_info "OS family: $OS_FAMILY"
```

rather than:

```bash
log_success "OS family: $OS_FAMILY"
```

### Section Headers

Introduced `log_section()` to visually separate major installation phases.

The goal is to make the installer readable without depending on terminal colors.

Major phases may include:

```text
System Detection
Privilege Check
Package Installation
Configuration
```

Avoid creating a section for every individual operation.

---

## 2026-08-23 — Symlink Manager

### Module Naming

Created:

```text
scripts/links.sh
```

The name `links.sh` was deliberately chosen over `dotfiles.sh`.

The repository itself is already a dotfiles project; `links.sh` more accurately describes the module's responsibility.

### `link_file()`

Implemented the initial primitive for safely linking a source to a destination.

The intended behavior is:

1. Missing destination → create symlink.
2. Correct existing symlink → skip.
3. Incorrect existing symlink → replace.
4. Existing real file → back up before replacement.
5. Existing real directory → preserve through backup before replacement.

### `backup_file()`

Implemented the initial backup mechanism.

Runtime backups are created next to the user's existing configuration, for example:

```text
~/.zshrc.backup-YYYYMMDD-HHMMSS
```

They are not stored in the repository's `backup/` directory.

The implementation currently avoids overwriting an existing backup filename.

### Testing Strategy

Before integrating `links.sh` into the main installer, filesystem behavior is being tested in a temporary directory.

Current test environment:

```text
/tmp/dotfiles-link-test/
```

The real `$HOME` should not be used for destructive symlink testing until the behavior has been validated.

---

## Current Project State

At the time of this history entry:

- Installer foundation is working.
- Linux/Arch environment detection is working.
- OS family and distribution are separated.
- Linux sudo validation is implemented.
- Arch package installation is implemented.
- macOS/Homebrew package installation path is implemented.
- Logging semantics and section formatting are established.
- `scripts/links.sh` has been started.
- `backup_file()` and `link_file()` have been implemented.
- Symlink behavior is not yet fully validated.
- `links.sh` is not yet integrated into `install.sh`.

The next milestone is to finish testing and refining the symlink manager before integrating it into the main installation flow.

---

## 2026-08-26 — Recursive Symlink Deployment

### Home Deployment

Implemented `link_home()` in `scripts/links.sh` to map the repository's
`home/` tree into a target home directory. Top-level files and directories are
linked without hardcoded configuration paths; directory links preserve nested
configuration trees.

The deployment creates the destination home directory as needed and reuses
`link_file()` for safe replacement, backups, and idempotent re-runs.

### Installer Integration

Integrated the symlink module into `install.sh` through a dedicated
`Configuration` phase.

### Validation

Temporary-environment tests verified:

- Missing destinations
- Correct and incorrect symlinks
- Existing files and directories with backups
- Nested paths and names containing spaces
- Idempotent re-runs
- Missing source-directory failure
- Integrated installer configuration deployment with mocked package tooling

The real user home directory was not modified by these tests.

---

## 2026-08-26 — Standalone Zsh Configuration

Reworked `home/.zshrc` into a native Zsh baseline that does not require Oh My
Zsh, Powerlevel10k, or `zsh-z` to start successfully.

The baseline now provides environment defaults, history behavior, native
completion, portable aliases, Git aliases, and a small `mkcd` helper. Optional
commands such as `eza` and `tree` are detected before their aliases are added.

The configuration was validated with an isolated temporary `$HOME` and the
real user home was not modified.

---

## 2026-08-26 — Modular Shell Configuration and Starship

Split the standalone Zsh configuration into concern-based directories under
`home/.config/zsh/`, with `home/.zshrc` serving as the ordered loader for each
directory's `.zsh` modules.

Added Starship as the plugin/prompt layer and added `starship.toml` to the
managed configuration. Added `zsh` to the common declarative package
inventory and placed Starship in the Zsh integrations inventory. Powerlevel10k
and Oh My Zsh are no longer required.

Validation covered modular startup with and without Starship in an isolated
temporary home.

---

## 2026-08-26 — Interactive Zsh Integration Selection

Added a terminal selection phase named `ZSH Integrations`. Interactive runs
support arrow-key navigation, Space to toggle, and Enter to confirm.

Added `--non-interactive` support. Noninteractive runs enable every package
manifest under `packages/zsh-integrations/`, making the mode suitable for the
maintainer's personal installation workflow and future integrations.

The package inventory is split into one declarative file per integration so
future interactive options can be added without changing the package-manager
abstractions.

---

## 2026-08-26 — Persisted Integration Selection State

Persisted Zsh integration selections beneath
`$XDG_STATE_HOME/dotfiles/selections/zsh-integrations/` rather than inside the
repository or managed `~/.config` tree. State files are written atomically,
backed up when changed, and skipped when unchanged.

The Zsh loader reads the persisted state before loading integration modules,
so installation choices control runtime Starship activation as well as package
selection.

---

## 2026-08-26 — Git Identity and Remote Preflight

Removed personal Git identity values from the managed repository configuration.
The installer now stores machine-specific identity in
`~/.local/state/dotfiles/git/identity.gitconfig` and supports explicit
`--git-name` and `--git-email` arguments.

Added a Git setup phase that verifies remote read access. It does not attempt
to generate or register SSH keys automatically, and it does not imply that
write access is available.

Added standalone `scripts/ssh.sh` for explicit SSH setup. The workflow detects
or generates an Ed25519 key, uses `ssh-agent`, optionally registers the public
key through authenticated `gh`, verifies GitHub SSH access, and switches the
repository remote to SSH only after confirmation.

---

## 2026-08-31 — Pull Request Integration Workflow

Published the implementation through atomic feature branches and pull
requests. The foundation work was merged through PR #9, followed by the SSH
setup work through PR #10.

The repository now uses a PR-based workflow: changes are developed on feature
branches, pushed with `git push -u origin HEAD`, reviewed where possible, and
merged into `main`. Direct pushes to `main` are not part of the workflow.

---

## 2026-09-02 — Recursive Home Mapping and Login PATH Persistence

Revisited the home deployment implementation after an incorrect `.zshrc`
symlink target was observed. The linker now traverses `home/` recursively,
preserves existing real directories, and links each file or symlink at its
matching relative path. This prevents a source-root mismatch such as linking
`~/.zshrc` to `$DOTFILES_DIR/.zshrc` instead of
`$DOTFILES_DIR/home/.zshrc`.

Added `home/.zprofile` to load the shared environment module for login shells.
The PATH configuration retains the inherited PATH, includes `~/.local/bin`
and `~/bin`, and includes Hermes user-local directories when installed.
Behavior was verified in disposable temporary homes without modifying the real
user home.

---

## 2026-09-02 — Deferred Git Remote Validation

Moved the installer's Git setup phase to the end of the workflow, after package
installation and home configuration deployment. This allows a fresh machine to
finish its local dotfiles setup before Git identity or GitHub remote access is
validated. The Git behavior itself remains unchanged, and the standalone SSH
setup workflow is still not invoked automatically.

---

## 2026-09-02 — Package Installation Summary

Added package-installation reporting for installed and already-installed
package counts. The installer now follows the summary with a list of
applications installed during the current run for quick verification.
