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

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    log_info "Starting dotfiles installation..."

    detect_os
    detect_architecture
    validate_environment

    log_success "Operating system: $OS"
    log_success "Architecture: $ARCH"
    log_success "Home directory: $HOME_DIR"
    log_success "Dotfiles directory: $DOTFILES_DIR"

    log_success "Environment validated successfully."
}

main "$@"
