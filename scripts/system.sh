#!/usr/bin/env bash

detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then
                OS="arch"
            else
                OS="linux"
            fi
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
