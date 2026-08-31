#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Package list helpers
# ------------------------------------------------------------------------------

read_package_list() {
    local package_file="$1"
    local package

    while IFS= read -r package; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        printf '%s\n' "$package"
    done < "$package_file"
}

read_zsh_integration_packages() {
    local package_file
    local package_files=()

    shopt -s nullglob
    package_files=("$DOTFILES_DIR/packages/zsh-integrations"/*.txt)
    shopt -u nullglob

    if [[ "${NON_INTERACTIVE:-false}" == true ]]; then
        for package_file in "${package_files[@]}"; do
            read_package_list "$package_file"
        done
    elif [[ "${ZSH_INTEGRATION_STARSHIP:-0}" == 1 ]]; then
        read_package_list "$DOTFILES_DIR/packages/zsh-integrations/starship.txt"
    fi
}

# ------------------------------------------------------------------------------
# Arch Linux
# ------------------------------------------------------------------------------

install_arch_packages() {
    local package

    while IFS= read -r package; do
        if pacman -Q "$package" >/dev/null 2>&1; then
            log_skip "Package already installed: $package"
            continue
        fi

        log_info "Installing Arch package: $package"

        sudo pacman -S --needed --noconfirm "$package"

        log_success "Package installed: $package"
    done < <(
        read_package_list "$DOTFILES_DIR/packages/common.txt"
        read_package_list "$DOTFILES_DIR/packages/arch.txt"
        read_zsh_integration_packages
    )
}

# ------------------------------------------------------------------------------
# Linux
# ------------------------------------------------------------------------------

install_linux_packages() {
    case "$DISTRO" in
        arch)
            install_arch_packages
            ;;

        *)
            log_error "Unsupported Linux distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# macOS
# ------------------------------------------------------------------------------

install_macos_packages() {
    local package

    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew is not installed."
        log_error "Please install Homebrew before running the dotfiles installer."
        exit 1
    fi

    while IFS= read -r package; do
        if brew list --formula "$package" >/dev/null 2>&1; then
            log_skip "Package already installed: $package"
            continue
        fi

        log_info "Installing macOS package: $package"

        brew install "$package"

        log_success "Package installed: $package"
    done < <(
        read_package_list "$DOTFILES_DIR/packages/common.txt"
        read_package_list "$DOTFILES_DIR/packages/macos.txt"
        read_zsh_integration_packages
    )
}

# ------------------------------------------------------------------------------
# Package installation
# ------------------------------------------------------------------------------

install_packages() {
    case "$OS_FAMILY" in
        linux)
            install_linux_packages
            ;;

        macos)
            install_macos_packages
            ;;

        *)
            log_error "Unsupported OS family: $OS_FAMILY"
            exit 1
            ;;
    esac
}
