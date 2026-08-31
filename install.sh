#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="$HOME"
NON_INTERACTIVE=false
REQUIRE_REMOTE=false

# ------------------------------------------------------------------------------
# Modules
# ------------------------------------------------------------------------------

source "$DOTFILES_DIR/scripts/logging.sh"
source "$DOTFILES_DIR/scripts/system.sh"
source "$DOTFILES_DIR/scripts/packages.sh"
source "$DOTFILES_DIR/scripts/links.sh"
source "$DOTFILES_DIR/scripts/selection.sh"
source "$DOTFILES_DIR/scripts/git.sh"

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --require-remote)
                REQUIRE_REMOTE=true
                shift
                ;;
            --git-name)
                [[ $# -ge 2 ]] || {
                    log_error "Missing value for --git-name."
                    exit 1
                }
                DOTFILES_GIT_NAME="$2"
                shift 2
                ;;
            --git-email)
                [[ $# -ge 2 ]] || {
                    log_error "Missing value for --git-email."
                    exit 1
                }
                DOTFILES_GIT_EMAIL="$2"
                shift 2
                ;;
            --help)
                printf 'Usage: %s [--non-interactive] [--require-remote]\n' "${BASH_SOURCE[0]}"
                printf '       [--git-name NAME] [--git-email EMAIL]\n'
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_arguments "$@"

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

    log_section "Git Setup"

    configure_git_identity "$HOME_DIR"
    verify_git_remote

    log_section "ZSH Integrations"

    select_zsh_integrations
    write_zsh_integration_state "$HOME_DIR"

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
