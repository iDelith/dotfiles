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
