#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# System detection
# ------------------------------------------------------------------------------

detect_system() {
    case "$(uname -s)" in
        Linux)
            OS_FAMILY="linux"

            if [[ -f /etc/arch-release ]]; then
                DISTRO="arch"
            else
                DISTRO="unknown"
            fi
            ;;

        Darwin)
            OS_FAMILY="macos"
            DISTRO="macos"
            ;;

        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

detect_architecture() {
    ARCH="$(uname -m)"
}

# ------------------------------------------------------------------------------
# Environment validation
# ------------------------------------------------------------------------------

validate_environment() {
    [[ -d "$DOTFILES_DIR/.git" ]] || {
        log_error "This does not appear to be a Git repository."
        exit 1
    }

    [[ -d "$HOME_DIR" ]] || {
        log_error "Home directory does not exist: $HOME_DIR"
        exit 1
    }
}

validate_sudo() {
    if ! sudo -v; then
        log_error "Unable to obtain administrative privileges."
        exit 1
    fi

    log_success "Administrative privileges confirmed."
}
