#!/usr/bin/env bash

log_info() {
    printf '[INFO] %s\n' "$1"
}

log_success() {
    printf '[ OK ] %s\n' "$1"
}

log_error() {
    printf '[ERROR] %s\n' "$1" >&2
}
