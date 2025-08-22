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
