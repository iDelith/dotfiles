#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="$HOME"

# ------------------------------------------------------------------------------
# Modules
# ------------------------------------------------------------------------------

source "$DOTFILES_DIR/scripts/logging.sh"
source "$DOTFILES_DIR/scripts/system.sh"
source "$DOTFILES_DIR/scripts/packages.sh"
source "$DOTFILES_DIR/scripts/links.sh"

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    log_info "Starting dotfiles installation..."

    log_section "System Detection"

    detect_system
    detect_architecture
    validate_environment

    log_info "OS family: $OS_FAMILY"
    log_info "Distribution: $DISTRO"
    log_info "Architecture: $ARCH"
    log_info "Home directory: $HOME_DIR"
    log_info "Dotfiles directory: $DOTFILES_DIR"
    log_info "Environment validated successfully."

    log_section "Privillege Check"

    if [[ "$OS_FAMILY" == "linux" ]]; then
        log_info "Checking administrative privileges..."
        validate_sudo
    fi

    log_section "Package installation"

    install_packages

    log_section "Symbolic Link Management"

    link_home "$DOTFILES_DIR/home" "$HOME_DIR"

    log_success "Installation completed successfully."
}

main "$@"
