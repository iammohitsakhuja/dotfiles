#!/usr/bin/env bash

# Shared backup utilities for dotfiles scripts
# This file provides consistent backup operations and path management.

# Source logging utilities for die function
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# Constants for backup operations
readonly BACKUP_BASE_DIR="${HOME}/.backup/dotfiles"
readonly MANIFEST_FILENAME="backup-manifest.json"
readonly TIMESTAMP_PATTERN="^[0-9]{8}-[0-9]{6}$"

# Get the base backup directory path
get_backup_base_dir() {
    echo "${BACKUP_BASE_DIR}"
}

# Get backup directory path for a specific timestamp
get_backup_dir_by_timestamp() {
    local timestamp="$1"
    echo "${BACKUP_BASE_DIR}/${timestamp}"
}

# Get manifest file path for a backup directory
get_manifest_file_path() {
    local backup_dir="$1"
    echo "${backup_dir}/${MANIFEST_FILENAME}"
}

# Generate a new timestamp for backup creation
generate_backup_timestamp() {
    date +%Y%m%d-%H%M%S
}

# Validate backup timestamp format
validate_backup_timestamp() {
    local timestamp="$1"

    if [[ ! ${timestamp} =~ ${TIMESTAMP_PATTERN} ]]; then
        die "ERROR: Invalid timestamp format. Expected YYYYMMDD-HHMMSS (e.g., 20250811-143022)"
    fi
}

# Ensure backup directory structure exists with proper error handling
ensure_backup_structure() {
    local specific_backup_dir="$1"

    # Ensure that parent backup directory exists as a directory, not file
    if [[ -f "${HOME}/.backup" ]]; then
        die "ERROR: ${HOME}/.backup exists as a file. Cannot create backup directory structure."
    fi

    # Create the specific backup directory (includes parent creation)
    if ! mkdir -p "${specific_backup_dir}" 2>/dev/null; then
        die "ERROR: Failed to create backup directory: ${specific_backup_dir}. Check disk space and permissions."
    fi
}

# Find and return all available backup directories sorted by timestamp (newest first)
find_backup_directories() {
    local backup_dirs=()

    # Find backup directories and sort them (newest first)
    while IFS= read -r -d '' dir; do
        backup_dirs+=("${dir}")
    done < <(find "${BACKUP_BASE_DIR}" -maxdepth 1 -type d -name "[0-9]*" -print0 2>/dev/null | sort -rz)

    # Return array elements, one per line
    printf '%s\n' "${backup_dirs[@]}"
}

# Check if any backup directories exist
has_backup_directories() {
    local backup_dirs=()
    mapfile -t backup_dirs < <(find_backup_directories)
    ((${#backup_dirs[@]} > 0))
}

# Validate that a backup directory exists and has a valid manifest
validate_backup_directory() {
    local backup_dir="$1"
    local manifest_file=$(get_manifest_file_path "${backup_dir}")

    if [[ ! -d ${backup_dir} ]]; then
        die "ERROR: Backup directory not found: ${backup_dir}"
    fi

    if [[ ! -f ${manifest_file} ]]; then
        die "ERROR: Backup manifest file not found: ${manifest_file}"
    fi

    # Validate JSON format
    if ! jq empty "${manifest_file}" 2>/dev/null; then
        die "ERROR: Invalid JSON format in manifest file"
    fi

    # Check if any files were successfully backed up
    local backed_up_count=$(jq -r '.summary.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0")
    if [[ ${backed_up_count} -eq 0 ]]; then
        die "ERROR: No successfully backed up files found in manifest"
    fi

    echo "${manifest_file}"
}

# Extract backup metadata from manifest file
get_backup_metadata() {
    local manifest_file="$1"
    local field="$2"

    case "${field}" in
    "date")
        jq -r '.metadata.backup_date' "${manifest_file}" 2>/dev/null || echo "Unknown"
        ;;
    "file_count")
        jq -r '.summary.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0"
        ;;
    "repository_path")
        jq -r '.metadata.repository_path' "${manifest_file}" 2>/dev/null || echo "Unknown"
        ;;
    *)
        die "ERROR: Unknown metadata field: ${field}"
        ;;
    esac
}

# Get list of files that were successfully backed up
get_backed_up_files() {
    local manifest_file="$1"
    jq -r '.files[] | select(.status == "moved_successfully") | .path' "${manifest_file}"
}

# Remove empty backup directory if no files were backed up
cleanup_empty_backup_dir() {
    local backup_dir="$1"
    rmdir "${backup_dir}" 2>/dev/null
}
