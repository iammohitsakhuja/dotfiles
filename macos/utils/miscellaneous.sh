#!/usr/bin/env bash

# Miscellaneous Shared utilities for dotfiles scripts

# Update a field in a JSON manifest file using jq
update_manifest_field() {
    local manifest_file="$1"
    local jq_expression="$2"
    shift 2

    local temp_manifest=$(mktemp)
    jq "${jq_expression}" "$@" "${manifest_file}" >"${temp_manifest}"
    mv "${temp_manifest}" "${manifest_file}"
}

# Keep sudo alive with proper cleanup by refreshing the timestamp periodically
# This function runs a background process that refreshes sudo credentials every 50 seconds
# and automatically cleans up on script exit
sudo_keepalive() {
    while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done &
    SUDO_PID=$!
    # Ensure cleanup on script exit
    trap 'kill ${SUDO_PID} 2>/dev/null' EXIT
}
