#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

SSH_KEY_PATH="${DOTFILES_SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
SSH_REMOTE_URL=""

usage() {
    cat <<'EOF'
Usage: scripts/ssh.sh [options]

Options:
  --key-path PATH  Use PATH for the Ed25519 key pair
  --help           Show this help message

Environment:
  DOTFILES_SSH_KEY_PATH  Override the default key path
EOF
}

get_origin_url() {
    git remote get-url origin
}

get_github_ssh_url() {
    local remote_url="$1"
    local repository

    case "$remote_url" in
        https://github.com/*)
            repository="${remote_url#https://github.com/}"
            ;;
        git@github.com:*)
            repository="${remote_url#git@github.com:}"
            ;;
        *)
            return 1
            ;;
    esac

    repository="${repository%.git}"
    printf 'git@github.com:%s.git\n' "$repository"
}

ensure_ssh_key() {
    local key_directory
    local email

    key_directory="$(dirname "$SSH_KEY_PATH")"
    mkdir -p "$key_directory"
    chmod 700 "$key_directory"

    if [[ -e "$SSH_KEY_PATH" || -L "$SSH_KEY_PATH" ]]; then
        [[ -f "$SSH_KEY_PATH" ]] || {
            log_error "SSH key path is not a regular file: $SSH_KEY_PATH"
            return 1
        }
        log_skip "SSH private key already exists: $SSH_KEY_PATH"
        return 0
    fi

    email="${DOTFILES_GIT_EMAIL:-$(git config --global --get user.email 2>/dev/null || true)}"
    log_info "Generating Ed25519 SSH key: $SSH_KEY_PATH"
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_PATH"
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "$SSH_KEY_PATH.pub"
    log_success "SSH key generated."
}

ensure_ssh_agent() {
    if ssh-add -l >/dev/null 2>&1; then
        log_skip "SSH key agent already has an identity."
        return 0
    fi

    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)" >/dev/null
    fi

    ssh-add "$SSH_KEY_PATH"
    log_success "SSH key added to the agent."
}

register_github_key() {
    local public_key="$SSH_KEY_PATH.pub"
    local title
    local answer

    printf '\nPublic SSH key:\n\n'
    cat "$public_key"
    printf '\n'

    if ! command -v gh >/dev/null 2>&1; then
        log_info "GitHub CLI is unavailable; register the public key manually."
        printf 'GitHub → Settings → SSH and GPG keys → New SSH key\n'
        [[ -t 0 && -t 1 ]] || {
            log_error "Run this script interactively after registering the public key."
            return 1
        }
        printf 'Press ENTER after registering the key with GitHub. '
        IFS= read -r
        return 0
    fi

    if ! gh auth status >/dev/null 2>&1; then
        log_info "GitHub CLI is not authenticated; register the public key manually."
        printf 'Authenticate with gh, then run: gh ssh-key add %s\n' "$public_key"
        [[ -t 0 && -t 1 ]] || {
            log_error "Run this script interactively after registering the public key."
            return 1
        }
        printf 'Press ENTER after registering the key with GitHub. '
        IFS= read -r
        return 0
    fi

    printf 'Register this key with GitHub using the authenticated gh account? [y/N] '
    IFS= read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] || {
        log_info "GitHub key registration skipped."
        return 0
    }

    title="dotfiles-$(hostname -s 2>/dev/null || hostname)"
    gh ssh-key add "$public_key" --title "$title"
    log_success "SSH public key registered with GitHub."
}

verify_github_ssh() {
    local output
    local output_file

    if [[ -t 0 && -t 1 ]]; then
        output_file="$(mktemp)"
        ssh -T git@github.com 2>&1 | tee "$output_file" || true
        output="$(cat "$output_file")"
        rm "$output_file"
    else
        output="$(ssh -T -o BatchMode=yes git@github.com 2>&1 || true)"
    fi

    if [[ "$output" == *"successfully authenticated"* ]]; then
        log_success "GitHub SSH authentication verified."
        return 0
    fi

    log_info "GitHub SSH authentication is not verified yet."
    printf '%s\n' "$output" >&2
    return 1
}

switch_origin_to_ssh() {
    local current_url="$1"
    local ssh_url="$2"
    local answer

    if [[ "$current_url" == "$ssh_url" ]]; then
        log_skip "Origin already uses SSH: $ssh_url"
        return 0
    fi

    printf 'Change origin from %s to %s? [Y/n] ' "$current_url" "$ssh_url"
    IFS= read -r answer
    if [[ -n "$answer" && ! "$answer" =~ ^[Yy]$ ]]; then
        log_info "Origin URL unchanged."
        return 0
    fi

    git remote set-url origin "$ssh_url"
    [[ "$(get_origin_url)" == "$ssh_url" ]] || {
        log_error "Origin URL verification failed."
        return 1
    }
    log_success "Origin now uses SSH: $ssh_url"
}

main() {
    local argument
    local origin_url

    while (($# > 0)); do
        case "$1" in
            --key-path)
                [[ $# -ge 2 ]] || {
                    log_error "Missing value for --key-path."
                    return 1
                }
                SSH_KEY_PATH="$2"
                shift 2
                ;;
            --help)
                usage
                return 0
                ;;
            *)
                log_error "Unknown argument: $1"
                usage >&2
                return 1
                ;;
        esac
    done

    git rev-parse --show-toplevel >/dev/null || {
        log_error "Run this script from inside a Git repository."
        return 1
    }

    origin_url="$(get_origin_url)"
    SSH_REMOTE_URL="$(get_github_ssh_url "$origin_url" || true)"
    [[ -n "$SSH_REMOTE_URL" ]] || {
        log_error "Origin is not a supported GitHub URL: $origin_url"
        return 1
    }

    log_section "SSH Setup"
    ensure_ssh_key
    ensure_ssh_agent
    register_github_key

    if ! verify_github_ssh; then
        log_info "Complete GitHub key registration, then rerun this script."
        return 1
    fi

    switch_origin_to_ssh "$origin_url" "$SSH_REMOTE_URL"
    git ls-remote --exit-code origin HEAD >/dev/null
    log_success "SSH remote read access verified."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
