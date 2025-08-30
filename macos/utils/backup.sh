#!/usr/bin/env bash

# Shared backup utilities for dotfiles scripts
# This file provides consistent backup operations and path management.

# Source utilities for die function
source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/miscellaneous.sh"

# Constants for backup operations
readonly BACKUP_BASE_DIR="${HOME}/.backup/dotfiles"
readonly MANIFEST_FILENAME="backup-manifest.json"
readonly TIMESTAMP_PATTERN="^[0-9]{8}-[0-9]{6}$"

# Non-stow files to backup (absolute paths)
readonly NON_STOW_FILES=(
    "${HOME}/.gitconfig"
    # Add more files as needed
)

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
    local dir
    while IFS= read -r dir; do
        backup_dirs+=("${dir}")
    done < <(find_backup_directories)

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
    local backed_up_count=$(jq -r '.summary.total.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0")
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
        jq -r '.summary.total.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0"
        ;;
    "repository_path")
        jq -r '.metadata.repository_path' "${manifest_file}" 2>/dev/null || echo "Unknown"
        ;;
    *)
        die "ERROR: Unknown metadata field: ${field}"
        ;;
    esac
}

# Get list of stow files that were successfully backed up
get_backed_up_stow_files() {
    local manifest_file="$1"
    # Output a compact JSON object to avoid splitting it across multiple lines.
    jq -c '.files.stow[] | select(.status == "moved_successfully") | {path}' "${manifest_file}"
}

# Get list of non-stow files that were successfully backed up (with source locations)
get_backed_up_non_stow_files() {
    local manifest_file="$1"
    # Output a compact JSON object to avoid splitting it across multiple lines.
    jq -c '.files.non_stow[] | select(.status == "moved_successfully") | {path, source_location}' "${manifest_file}"
}

# Get count of successfully backed up stow files
get_stow_file_count() {
    local manifest_file="$1"
    jq -r '.summary.stow.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0"
}

# Get count of successfully backed up non-stow files
get_non_stow_file_count() {
    local manifest_file="$1"
    jq -r '.summary.non_stow.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0"
}

# Get total count of successfully backed up files
get_total_file_count() {
    local manifest_file="$1"
    jq -r '.summary.total.files_backed_up' "${manifest_file}" 2>/dev/null || echo "0"
}

# Remove empty backup directory if no files were backed up
cleanup_empty_backup_dir() {
    local backup_dir="$1"
    rmdir "${backup_dir}" 2>/dev/null
}

# Detect conflicts between stow and existing files
detect_stow_conflicts() {
    local stow_dir="$1"
    local target_dir="$2"

    # Use stow simulation with verbose output to detect actual conflicts. Do not fold the tree.
    local stow_output=$(stow -n -d "${stow_dir}" -t "${target_dir}" --no-folding home --verbose=3 2>&1)

    # Filter files that are causing conflicts - catch both types of conflicts
    local stowing_conflicts=$(echo "${stow_output}" | grep "CONFLICT when stowing" | sed -n 's/.*over existing target \([^[:space:]]*\).*/\1/p' | tr '\n' ',' | sed 's/,$//')
    local ownership_conflicts=$(echo "${stow_output}" | grep "CONFLICT when stowing" | sed -n 's/.*existing target is not owned by stow: \([^[:space:]]*\).*/\1/p' | tr '\n' ',' | sed 's/,$//')

    # TODO: Remove the need for `actual_conflicts` variable.
    # Combine both types of conflics.
    local actual_conflicts=$(printf "%s\n%s" "${stowing_conflicts}" "${ownership_conflicts}" | grep -v '^$' | sort -u | tr '\n' ',' | sed 's/,$//')

    # Return conflict information as a structured format
    echo "${stowing_conflicts}|${ownership_conflicts}|${actual_conflicts}"
}

# Detect non-stow conflicts (files not managed by stow)
detect_non_stow_conflicts() {
    local conflicts=()

    # Accept array elements as positional parameters
    for file_path in "$@"; do
        # Check if file already exists at the path. If yes, then it will conflict.
        if [[ -e ${file_path} ]]; then
            conflicts+=("${file_path}")
        fi
    done

    # Return comma-separated list
    local IFS=','
    echo "${conflicts[*]}"
}

# Create backup directory structure and initialize manifest
create_backup_manifest() {
    local backup_dir="$1"
    local stowing_conflicts="$2"
    local ownership_conflicts="$3"
    local non_stow_conflicts="$4"
    local stow_dir="$5"

    local manifest_file=$(get_manifest_file_path "${backup_dir}")

    # Check available disk space (require at least 100MB free)
    local available_space
    if ! available_space=$(df "${HOME}" | awk 'NR==2 {print $4}'); then
        die "ERROR: Failed to check available disk space for backup"
    fi
    # $available_space is in `KB`
    if [[ ${available_space} -lt 102400 ]]; then
        die "ERROR: Insufficient disk space for backup. At least 100MB required."
    fi

    # Create backup directory structure.
    print_action "Creating backup directory: ${backup_dir}"
    ensure_backup_structure "${backup_dir}"
    print_detail "Manifest file path: ${manifest_file}" 3

    # Count conflicts (handle empty strings properly)
    local stowing_count=0
    [[ -n ${stowing_conflicts} ]] && stowing_count=$(echo "${stowing_conflicts}" | tr ',' '\n' | grep -c .)
    echo "Stowing conflicts: ${stowing_conflicts}" >&2
    local ownership_count=0
    [[ -n ${ownership_conflicts} ]] && ownership_count=$(echo "${ownership_conflicts}" | tr ',' '\n' | grep -c .)
    echo "Ownership conflicts: ${ownership_conflicts}" >&2
    local stow_count=$((stowing_count + ownership_count))
    local non_stow_count=0
    [[ -n ${non_stow_conflicts} ]] && non_stow_count=$(echo "${non_stow_conflicts}" | tr ',' '\n' | grep -c .)
    local total_conflicts=$((stow_count + non_stow_count))

    print_action "Found conflicts: ${stow_count} stow conflicts (Stowing: ${stowing_conflicts}, Ownership: ${ownership_conflicts}), ${non_stow_count} non-stow conflicts"

    # Convert conflicts to JSON arrays
    local stowing_conflicts_json ownership_conflicts_json non_stow_conflicts_json

    if [[ -n ${stowing_conflicts} ]]; then
        stowing_conflicts_json=$(echo "${stowing_conflicts}" | tr ',' '\n' | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        stowing_conflicts_json="[]"
    fi

    if [[ -n ${ownership_conflicts} ]]; then
        ownership_conflicts_json=$(echo "${ownership_conflicts}" | tr ',' '\n' | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        ownership_conflicts_json="[]"
    fi

    if [[ -n ${non_stow_conflicts} ]]; then
        non_stow_conflicts_json=$(echo "${non_stow_conflicts}" | tr ',' '\n' | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        non_stow_conflicts_json="[]"
    fi

    # Create initial JSON structure
    cat >"${manifest_file}" <<EOF
{
  "metadata": {
    "backup_date": "$(date -Iseconds)",
    "repository_path": "${stow_dir}",
    "backup_version": "2.0"
  },
  "conflicts": {
    "stow": {
      "stowing_conflict_files": ${stowing_conflicts_json},
      "ownership_conflict_files": ${ownership_conflicts_json},
      "total_count": ${stow_count}
    },
    "non_stow": {
      "conflict_files": ${non_stow_conflicts_json},
      "total_count": ${non_stow_count}
    },
    "total_count": ${total_conflicts}
  },
  "files": {
    "stow": [],
    "non_stow": []
  },
  "summary": {
    "stow": {
      "files_backed_up": 0,
      "files_failed": 0,
      "backup_size_total": 0
    },
    "non_stow": {
      "files_backed_up": 0,
      "files_failed": 0,
      "backup_size_total": 0
    },
    "total": {
      "files_backed_up": 0,
      "files_failed": 0,
      "backup_size_total": 0
    }
  }
}
EOF

    echo "${manifest_file}"
}

add_stow_file_to_manifest() {
    local manifest_file="$1"
    local path="$2"
    local status="$3"
    local conflict_type="$4"
    local backup_size="$5"

    # shellcheck disable=SC2016
    update_manifest_field "${manifest_file}" \
        '.files.stow += [{"path": $path, "status": $status, "conflict_type": $conflict_type, "backup_size": $backup_size}]' \
        --arg path "${path}" \
        --arg status "${status}" \
        --arg conflict_type "${conflict_type}" \
        --argjson backup_size "${backup_size}"
}

add_non_stow_file_to_manifest() {
    local manifest_file="$1"
    local path="$2"
    local status="$3"
    local source_location="$4"
    local backup_size="$5"

    # shellcheck disable=SC2016
    update_manifest_field "${manifest_file}" \
        '.files.non_stow += [{"path": $path, "status": $status, "source_location": $source_location, "backup_size": $backup_size}]' \
        --arg path "${path}" \
        --arg status "${status}" \
        --arg source_location "${source_location}" \
        --argjson backup_size "${backup_size}"
}

# Backup conflicting stow files to the backup directory
backup_conflicting_stow_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local stowing_conflicts="$3"
    local ownership_conflicts="$4"

    # Counters
    local backed_up=0 failed=0 size=0

    # Process stow conflicts (relative paths from $HOME)
    local all_stow_conflicts="${stowing_conflicts},${ownership_conflicts}"
    IFS=',' read -ra stow_array <<<"${all_stow_conflicts}"

    for relative_path in "${stow_array[@]}"; do
        # Skip empty entries
        [[ -z ${relative_path} ]] && continue

        # Validate paths are relative and safe
        if [[ ${relative_path} =~ ^/ ]] || [[ ${relative_path} =~ \.\. ]]; then
            print_warning "Unsafe path detected: ${relative_path}"
            add_stow_file_to_manifest "${manifest_file}" "${relative_path}" "unsafe_path" "unknown" 0
            ((failed++))
            continue
        fi

        local target_file="${HOME}/${relative_path}"

        # Determine conflict type
        local conflict_type="unknown"
        if [[ ",${stowing_conflicts}," == *",${relative_path},"* ]]; then
            conflict_type="stowing"
        elif [[ ",${ownership_conflicts}," == *",${relative_path},"* ]]; then
            conflict_type="ownership"
        fi

        # Check if target file exists
        if [[ -e ${target_file} ]]; then
            # Get file size
            local file_size=0
            [[ -f ${target_file} ]] && file_size=$(stat -f%z "${target_file}" 2>/dev/null || echo 0)

            # Create path for backup storage
            local backup_file="${backup_dir}/stow/${relative_path}"
            local backup_parent_dir=$(dirname "${backup_file}")
            mkdir -p "${backup_parent_dir}"

            # Move file to backup location (atomic operation)
            if mv "${target_file}" "${backup_file}" 2>/dev/null; then
                add_stow_file_to_manifest "${manifest_file}" "${relative_path}" "moved_successfully" "${conflict_type}" "${file_size}"
                print_detail "Moved stow file to backup: ${relative_path}" 3
                ((backed_up++))
                ((size += file_size))
            else
                add_stow_file_to_manifest "${manifest_file}" "${relative_path}" "move_failed" "${conflict_type}" 0
                ((failed++))
                die "ERROR: Failed to move ${relative_path} to backup"
            fi
        else
            add_stow_file_to_manifest "${manifest_file}" "${relative_path}" "target_missing" "${conflict_type}" 0
            ((failed++))
            die "ERROR: Conflict file ${relative_path} doesn't exist at target"
        fi
    done

    echo "${backed_up}|${failed}|${size}"
}

# Backup conflicting non-stow files to the backup directory
backup_conflicting_non_stow_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local non_stow_conflicts="$3"

    # Counters
    local backed_up=0 failed=0 size=0

    # Process non-stow conflicts (absolute paths)
    IFS=',' read -ra non_stow_array <<<"${non_stow_conflicts}"

    for absolute_path in "${non_stow_array[@]}"; do
        # Skip empty entries
        [[ -z ${absolute_path} ]] && continue

        # Check if target file exists
        if [[ -e ${absolute_path} ]]; then
            # Get file size
            local file_size=0
            [[ -f ${absolute_path} ]] && file_size=$(stat -f%z "${absolute_path}" 2>/dev/null || echo 0)

            # Create relative path for backup storage
            local backup_relative="${absolute_path#/}"
            local backup_file="${backup_dir}/non_stow/${backup_relative}"
            local backup_parent_dir=$(dirname "${backup_file}")
            mkdir -p "${backup_parent_dir}"

            if mv "${absolute_path}" "${backup_file}" 2>/dev/null; then
                add_non_stow_file_to_manifest "${manifest_file}" "${backup_relative}" "moved_successfully" "${absolute_path}" "${file_size}"
                print_detail "Moved non-stow file to backup: ${absolute_path}" 3
                ((backed_up++))
                ((size += file_size))
            else
                add_non_stow_file_to_manifest "${manifest_file}" "${backup_relative}" "move_failed" "${absolute_path}" 0
                ((failed++))
                die "ERROR: Failed to move ${absolute_path} to backup"
            fi
        else
            add_non_stow_file_to_manifest "${manifest_file}" "${backup_relative}" "target_missing" "${absolute_path}" 0
            ((failed++))
            die "ERROR: Conflict file ${absolute_path} doesn't exist at target"
        fi
    done

    echo "${backed_up}|${failed}|${size}"
}

# Backup conflicting files to the backup directory
backup_conflicting_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local stowing_conflicts="$3"
    local ownership_conflicts="$4"
    local non_stow_conflicts="$5"

    # Backup stow conflicts
    local stow_conflicts_result=$(backup_conflicting_stow_files "${backup_dir}" "${manifest_file}" "${stowing_conflicts}" "${ownership_conflicts}" "${non_stow_conflicts}")
    local stow_backed_up stow_failed stow_size
    IFS='|' read -r stow_backed_up stow_failed stow_size <<<"${stow_conflicts_result}"

    # Backup non-stow conflicts
    local non_stow_conflicts_result=$(backup_conflicting_non_stow_files "${backup_dir}" "${manifest_file}" "${non_stow_conflicts}")
    local non_stow_backed_up non_stow_failed non_stow_size
    IFS='|' read -r non_stow_backed_up non_stow_failed non_stow_size <<<"${non_stow_conflicts_result}"

    # Return all counts
    echo "${stow_backed_up}|${stow_failed}|${stow_size}|${non_stow_backed_up}|${non_stow_failed}|${non_stow_size}"
}

# Update the final backup summary in the manifest
update_backup_manifest_summary() {
    local manifest_file="$1"
    local stow_backed_up="$2"
    local stow_failed="$3"
    local stow_size="$4"
    local non_stow_backed_up="$5"
    local non_stow_failed="$6"
    local non_stow_size="$7"

    # Calculate totals
    local total_backed_up=$((stow_backed_up + non_stow_backed_up))
    local total_failed=$((stow_failed + non_stow_failed))
    local total_size=$((stow_size + non_stow_size))

    # Update all summary sections
    # shellcheck disable=SC2016
    update_manifest_field "${manifest_file}" \
        '.summary.stow.files_backed_up = $stow_backed_up |
         .summary.stow.files_failed = $stow_failed |
         .summary.stow.backup_size_total = $stow_size |
         .summary.non_stow.files_backed_up = $non_stow_backed_up |
         .summary.non_stow.files_failed = $non_stow_failed |
         .summary.non_stow.backup_size_total = $non_stow_size |
         .summary.total.files_backed_up = $total_backed_up |
         .summary.total.files_failed = $total_failed |
         .summary.total.backup_size_total = $total_size' \
        --argjson stow_backed_up "${stow_backed_up}" \
        --argjson stow_failed "${stow_failed}" \
        --argjson stow_size "${stow_size}" \
        --argjson non_stow_backed_up "${non_stow_backed_up}" \
        --argjson non_stow_failed "${non_stow_failed}" \
        --argjson non_stow_size "${non_stow_size}" \
        --argjson total_backed_up "${total_backed_up}" \
        --argjson total_failed "${total_failed}" \
        --argjson total_size "${total_size}"
}

# Main function to backup existing files before stow operations
# Returns backup directory path if backup was created, empty string otherwise
backup_existing_files() {
    local backup_flag="$1"
    local stow_dir="$2"

    if [[ ${backup_flag} == 0 ]]; then
        print_action "Skipping backup as requested..."
        echo "" # Return empty string for no backup
        return 0
    fi

    print_action "Checking for existing files that would be overwritten..."

    # Create timestamped backup directory
    local backup_timestamp=$(generate_backup_timestamp)
    local backup_dir=$(get_backup_dir_by_timestamp "${backup_timestamp}")

    # Detect stow conflicts
    local stow_conflict_data=$(detect_stow_conflicts "${stow_dir}" "${HOME}")
    local stowing_conflicts ownership_conflicts actual_stow_conflicts
    IFS='|' read -r stowing_conflicts ownership_conflicts actual_stow_conflicts <<<"${stow_conflict_data}"

    # Detect non-stow conflicts
    local non_stow_conflicts=$(detect_non_stow_conflicts "${NON_STOW_FILES[@]}")

    # Check if any conflicts exist
    if [[ -z ${actual_stow_conflicts} ]] && [[ -z ${non_stow_conflicts} ]]; then
        print_success "No existing files would be overwritten. Proceeding without backup."
        echo "" # Return empty string for no backup
        return 0
    fi

    # Create backup manifest and backup directory structure
    local manifest_file=$(create_backup_manifest "${backup_dir}" "${stowing_conflicts}" "${ownership_conflicts}" "${non_stow_conflicts}" "${stow_dir}")

    # Backup all conflicting files
    local backup_results=$(backup_conflicting_files "${backup_dir}" "${manifest_file}" "${stowing_conflicts}" "${ownership_conflicts}" "${non_stow_conflicts}")

    # Parse backup results: stow_backed_up|stow_failed|stow_size|non_stow_backed_up|non_stow_failed|non_stow_size
    local stow_backed_up stow_failed stow_size non_stow_backed_up non_stow_failed non_stow_size
    IFS='|' read -r stow_backed_up stow_failed stow_size non_stow_backed_up non_stow_failed non_stow_size <<<"${backup_results}"

    # Update manifest summary
    update_backup_manifest_summary "${manifest_file}" \
        "${stow_backed_up}" "${stow_failed}" "${stow_size}" \
        "${non_stow_backed_up}" "${non_stow_failed}" "${non_stow_size}"

    local total_backed_up=$((stow_backed_up + non_stow_backed_up))

    if [[ ${total_backed_up} -gt 0 ]]; then
        echo "" >&2
        print_success "Backup completed successfully!"
        print_detail "Location: ${backup_dir}" 3
        print_detail "Stow files backed up: ${stow_backed_up}" 3
        print_detail "Non-stow files backed up: ${non_stow_backed_up}" 3
        print_detail "Total files backed up: ${total_backed_up}" 3
        print_detail "Manifest file path: ${manifest_file}" 3
        echo "" >&2
        # Return the backup directory path to stdout
        echo "${backup_dir}"
    else
        # Remove empty backup directory if no files were actually backed up
        cleanup_empty_backup_dir "${backup_dir}"
        print_success "No files needed backup. Proceeding with installation."
        echo "" >&2
        echo "" # Return empty string for no backup
    fi

    return 0
}
