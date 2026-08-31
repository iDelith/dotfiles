#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Backup
# ------------------------------------------------------------------------------

backup_file() {
    local file="$1"
    local timestamp
    local backup

    timestamp="$(date '+%Y%m%d-%H%M%S')"
    backup="${file}.backup-${timestamp}"

    while [[ -e "$backup" || -L "$backup" ]]; do
        timestamp="$(date '+%Y%m%d-%H%M%S')"
        backup="${file}.backup-${timestamp}"
        sleep 1
    done

    log_info "Creating backup: $backup"

    mv "$file" "$backup"

    log_success "Backup created: $backup"
}


# ------------------------------------------------------------------------------
# File linking
# ------------------------------------------------------------------------------

link_file() {
    local source="$1"
    local destination="$2"

    if [[ -L "$destination" ]]; then
        if [[ "$(readlink "$destination")" == "$source" ]]; then
            log_skip "Already linked: $destination"
            return
        fi

        log_info "Replacing existing symlink: $destination"
        rm "$destination"
    elif [[ -e "$destination" ]]; then
        log_info "Existing file found: $destination"
        backup_file "$destination"
    fi

    ln -s "$source" "$destination"

    log_success "Linked: $destination"
}


# ------------------------------------------------------------------------------
# Recursive home deployment
# ------------------------------------------------------------------------------

link_home() {
    local source_root="$1"
    local destination_root="$2"
    local source
    local relative
    local destination
    local parent
    local entries=()

    if [[ ! -d "$source_root" ]]; then
        log_error "Home source directory does not exist: $source_root"
        return 1
    fi

    mkdir -p "$destination_root" || {
        log_error "Unable to create home destination: $destination_root"
        return 1
    }

    shopt -s nullglob dotglob
    entries=("$source_root"/*)
    shopt -u nullglob dotglob

    for source in "${entries[@]}"; do
        relative="${source#"$source_root"/}"
        destination="$destination_root/$relative"
        parent="$(dirname "$destination")"

        mkdir -p "$parent" || {
            log_error "Unable to create parent directory: $parent"
            return 1
        }

        link_file "$source" "$destination" || return 1
    done
}
