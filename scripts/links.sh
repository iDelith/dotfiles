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

link_tree() {
    local source_dir="$1"
    local destination_dir="$2"
    local source
    local name
    local destination
    local entries=()

    shopt -s nullglob dotglob
    entries=("$source_dir"/*)
    shopt -u nullglob dotglob

    for source in "${entries[@]}"; do
        name="${source##*/}"
        destination="$destination_dir/$name"

        if [[ -d "$source" && ! -L "$source" ]]; then
            if [[ -L "$destination" ]]; then
                if [[ "$(readlink "$destination")" == "$source" ]]; then
                    log_skip "Already linked directory: $destination"
                    continue
                fi
                backup_file "$destination"
            elif [[ -e "$destination" ]]; then
                if [[ ! -d "$destination" ]]; then
                    backup_file "$destination"
                    mkdir "$destination"
                fi
            else
                mkdir -p "$destination"
            fi

            link_tree "$source" "$destination" || return 1
        else
            mkdir -p "$destination_dir" || {
                log_error "Unable to create parent directory: $destination_dir"
                return 1
            }
            link_file "$source" "$destination" || return 1
        fi
    done
}


link_home() {
    local source_root="$1"
    local destination_root="$2"

    if [[ ! -d "$source_root" ]]; then
        log_error "Home source directory does not exist: $source_root"
        return 1
    fi

    mkdir -p "$destination_root" || {
        log_error "Unable to create home destination: $destination_root"
        return 1
    }

    link_tree "$source_root" "$destination_root"
}
