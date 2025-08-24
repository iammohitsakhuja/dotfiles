#!/usr/bin/env bash

# Enable strict error handling
set -e          # Exit on any command failure
set -o pipefail # Fail on any command in a pipeline

# Source shared utilities
source "$(dirname "$0")/utils/logging.sh"
source "$(dirname "$0")/utils/platform.sh"
source "$(dirname "$0")/utils/backup.sh"

# Initialize option variables.
list_backups=0
backup_timestamp=""
dry_run=0

show_help() {
    echo "Usage: ./restore.sh [-h | --help] [--list] [--backup <timestamp>] [--dry-run]"
    echo "       -h, --help           | Show this help."
    echo "       --list               | List available backup directories."
    echo "       --backup <timestamp> | Restore from specific backup (format: YYYYMMDD-HHMMSS)."
    echo "       --dry-run            | Preview what would be restored without making changes."
    echo ""
    echo "Examples:"
    echo "  ./restore.sh --list                    # Show available backups"
    echo "  ./restore.sh                           # Interactive restore from latest backup"
    echo "  ./restore.sh --backup 20250811-143022  # Restore from specific backup"
    echo "  ./restore.sh --dry-run                 # Preview restoration actions"
    echo ""
    echo "This script helps restore original dotfiles from backups created during failed"
    echo "or interrupted installations. It cleans up stow-managed symlinks and moves"
    echo "your original configuration files back from backup locations."
}

# Parse command line arguments.
while :; do
    case $1 in
    -h | -\? | --help)
        show_help
        exit
        ;;
    --list)
        list_backups=1
        shift
        ;;
    --backup)
        if [[ -n $2 ]]; then
            backup_timestamp="$2"
            shift 2
        else
            die 'ERROR: "--backup" requires a non-empty option argument.'
        fi
        ;;
    --backup=?*)
        backup_timestamp=${1#*=}
        shift
        ;;
    --backup=)
        die 'ERROR: "--backup" requires a non-empty option argument.'
        ;;
    --dry-run)
        dry_run=1
        shift
        ;;
    *)
        break
        ;;
    esac
done

# Get the stow directory (directory containing this script).
STOW_DIR=$(cd "$(dirname "$0")" && pwd)

# Validate we found the correct directory with home/ package
if [[ ! -d "${STOW_DIR}/home" ]]; then
    die "ERROR: Could not locate home/ directory for stow operations."
fi

# Validate stow is available
if ! command -v stow >/dev/null 2>&1; then
    die "ERROR: GNU Stow is required but not installed"
fi

# Validate jq is available for JSON processing
if ! command -v jq >/dev/null 2>&1; then
    die "ERROR: jq is required for JSON manifest processing but not installed"
fi

# Function to find and list available backup directories
list_available_backups() {
    local backup_dirs=()
    local dir
    while IFS= read -r dir; do
        backup_dirs+=("${dir}")
    done < <(find_backup_directories)

    if ((${#backup_dirs[@]} == 0)); then
        echo "No backup directories found in $(get_backup_base_dir)"
        return 1
    fi

    print_subheader "Available backups"

    for backup_dir in "${backup_dirs[@]}"; do
        [[ -z ${backup_dir} ]] && continue
        local timestamp=$(basename "${backup_dir}")
        local manifest_file=$(get_manifest_file_path "${backup_dir}")

        if [[ -f ${manifest_file} ]]; then
            # Extract backup date and detailed file counts from JSON
            local backup_date=$(get_backup_metadata "${manifest_file}" "date")
            local stow_count=$(get_stow_file_count "${manifest_file}")
            local non_stow_count=$(get_non_stow_file_count "${manifest_file}")
            local total_count=$(get_total_file_count "${manifest_file}")

            echo "  ${timestamp} (Files backed up - Total: ${total_count} [Stow: ${stow_count}, Non-Stow: ${non_stow_count}])"
            print_detail "Date: ${backup_date}" 2
            print_detail "Location: ${backup_dir}" 2
        else
            echo "  ${timestamp} (manifest file missing - backup may be incomplete)"
        fi
        echo ""
    done

    return 0
}

# Function to clean up stow-managed symlinks
cleanup_stow_symlinks() {
    local dry_run_flag="$1"

    print_step 1 3 "Cleaning up stow-managed symlinks"

    print_action "Removing stow-managed symlinks from ${HOME}..."

    # Execute stow command with appropriate flags
    if [[ ${dry_run_flag} == "dry-run" ]]; then
        # Use stow's native simulation mode - show all output
        stow -n -D -d "${STOW_DIR}" -t "${HOME}" --no-folding home --verbose=2
        local exit_code=$?
    else
        # Execute actual stow removal - show all output
        stow -D -d "${STOW_DIR}" -t "${HOME}" --no-folding home --verbose=2
        local exit_code=$?
    fi

    if [[ ${exit_code} -eq 0 ]]; then
        print_success "Stow symlinks cleaned up successfully"
    else
        print_warning "Some stow operations could not be completed (this may be normal if installation was incomplete)"
    fi
    echo ""
}

# Function to restore stow files from backup
restore_stow_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    print_action "Restoring stow-managed files..." >&2

    local files_to_restore=$(get_backed_up_stow_files "${manifest_file}")
    if [[ -z ${files_to_restore} ]]; then
        print_warning "No stow files to restore from this backup" >&2
        echo "0|0|0" # Return stow_restored|stow_failed|stow_skipped
        return 0
    fi

    local files_restored=0
    local files_failed=0
    local files_skipped=0

    # Process JSON objects line by line
    while IFS= read -r json_entry; do
        [[ -z ${json_entry} ]] && continue

        # Extract path from JSON object
        local relative_path=$(echo "${json_entry}" | jq -r '.path')

        # Validate we got valid data
        if [[ ${relative_path} == "null" ]]; then
            print_warning "Invalid JSON entry, skipping" >&2
            ((files_failed++))
            continue
        fi

        local backup_file="${backup_dir}/stow/${relative_path}"
        local target_file="${HOME}/${relative_path}"

        # Validate paths are safe
        if [[ ${relative_path} =~ ^/ ]] || [[ ${relative_path} =~ \.\. ]]; then
            print_warning "Unsafe path detected, skipping: ${relative_path}" >&2
            ((files_failed++))
            continue
        fi

        # Check if backup file exists
        if [[ ! -f ${backup_file} ]]; then
            print_warning "Stow backup file not found, skipping: ${relative_path}" >&2
            ((files_failed++))
            continue
        fi

        # Show what file will be restored
        print_action "Restoring stow file: ${relative_path}" >&2
        print_detail "From: ${backup_file}" 3 >&2
        print_detail "To: ${target_file}" 3 >&2

        if [[ ${dry_run_flag} == "dry-run" ]]; then
            # In dry-run mode, just count and continue
            ((files_restored++))
        else
            # Create target directory if it doesn't exist
            local target_dir=$(dirname "${target_file}")
            if [[ ! -d ${target_dir} ]]; then
                mkdir -p "${target_dir}"
            fi

            # Check if target file already exists
            if [[ -e ${target_file} ]]; then
                print_warning "Target file already exists: ${relative_path}" >&2
                echo -n "  Choose action - (r)eplace, (s)kip, (q)uit: " >&2
                read -r action </dev/tty
                case "${action}" in
                r | R | replace)
                    print_action "Replacing existing file..." >&2
                    ;;
                s | S | skip)
                    print_action "Skipping file..." >&2
                    ((files_skipped++))
                    continue
                    ;;
                q | Q | quit)
                    echo "Restoration cancelled by user." >&2
                    exit 0
                    ;;
                *)
                    print_action "Invalid choice, skipping file..." >&2
                    ((files_skipped++))
                    continue
                    ;;
                esac
            fi

            # Move file back from backup (atomic operation - reverse of backup)
            if mv "${backup_file}" "${target_file}" 2>/dev/null; then
                print_success "Restored stow file: ${relative_path}" >&2
                ((files_restored++))
            else
                print_warning "Failed to restore stow file: ${relative_path}" >&2
                ((files_failed++))
            fi
        fi
    done <<<"${files_to_restore}"

    # Return counts in format: restored|failed|skipped
    echo "${files_restored}|${files_failed}|${files_skipped}"
}

# Function to restore non-stow files from backup
restore_non_stow_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    print_action "Restoring non-stow files..." >&2

    local files_to_restore=$(get_backed_up_non_stow_files "${manifest_file}")
    if [[ -z ${files_to_restore} ]]; then
        print_warning "No non-stow files to restore from this backup" >&2
        echo "0|0|0" # Return non_stow_restored|non_stow_failed|non_stow_skipped
        return 0
    fi

    local files_restored=0
    local files_failed=0
    local files_skipped=0

    # Process JSON objects line by line
    while IFS= read -r json_entry; do
        [[ -z ${json_entry} ]] && continue

        # Extract path and source_location from JSON
        local backup_path=$(echo "${json_entry}" | jq -r '.path')
        local source_location=$(echo "${json_entry}" | jq -r '.source_location')

        # Validate we got valid data
        if [[ ${backup_path} == "null" ]] || [[ ${source_location} == "null" ]]; then
            print_warning "Invalid JSON entry, skipping" >&2
            ((files_failed++))
            continue
        fi

        local backup_file="${backup_dir}/non_stow/${backup_path}"
        local target_file="${source_location}"

        # Validate paths are safe for source_location
        if [[ ${source_location} =~ \.\. ]]; then
            print_warning "Unsafe source location detected, skipping: ${source_location}" >&2
            ((files_failed++))
            continue
        fi

        # Check if backup file exists
        if [[ ! -f ${backup_file} ]]; then
            print_warning "Non-stow backup file not found, skipping: ${backup_path}" >&2
            ((files_failed++))
            continue
        fi

        # Show what file will be restored
        print_action "Restoring non-stow file: ${source_location}" >&2
        print_detail "From: ${backup_file}" 3 >&2
        print_detail "To: ${target_file}" 3 >&2

        if [[ ${dry_run_flag} == "dry-run" ]]; then
            # In dry-run mode, just count and continue
            ((files_restored++))
        else
            # Create target directory if it doesn't exist
            local target_dir=$(dirname "${target_file}")
            if [[ ! -d ${target_dir} ]]; then
                mkdir -p "${target_dir}"
            fi

            # Check if target file already exists
            if [[ -e ${target_file} ]]; then
                print_warning "Target file already exists: ${source_location}" >&2
                echo -n "  Choose action - (r)eplace, (s)kip, (q)uit: " >&2
                read -r action </dev/tty
                case "${action}" in
                r | R | replace)
                    print_action "Replacing existing file..." >&2
                    ;;
                s | S | skip)
                    print_action "Skipping file..." >&2
                    ((files_skipped++))
                    continue
                    ;;
                q | Q | quit)
                    echo "Restoration cancelled by user." >&2
                    exit 0
                    ;;
                *)
                    print_action "Invalid choice, skipping file..." >&2
                    ((files_skipped++))
                    continue
                    ;;
                esac
            fi

            # Move file back from backup (atomic operation - reverse of backup)
            if mv "${backup_file}" "${target_file}" 2>/dev/null; then
                print_success "Restored non-stow file: ${source_location}" >&2
                ((files_restored++))
            else
                print_warning "Failed to restore non-stow file: ${source_location}" >&2
                ((files_failed++))
            fi
        fi
    done <<<"${files_to_restore}"

    # Return counts in format: restored|failed|skipped
    echo "${files_restored}|${files_failed}|${files_skipped}"
}

# Function to restore files from backup using dual workflow
restore_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    print_step 2 3 "Restoring original files from backup" >&2

    # Get file counts for initial check
    local stow_count=$(get_stow_file_count "${manifest_file}")
    local non_stow_count=$(get_non_stow_file_count "${manifest_file}")
    local total_count=$(get_total_file_count "${manifest_file}")

    if [[ ${total_count} -eq 0 ]]; then
        print_warning "No files to restore from this backup" >&2
        return 0
    fi

    echo "Files to restore - Total: ${total_count} (Stow: ${stow_count}, Non-Stow: ${non_stow_count})" >&2
    echo "" >&2

    # Restore stow files first
    local stow_results=$(restore_stow_files "${backup_dir}" "${manifest_file}" "${dry_run_flag}")
    local stow_restored stow_failed stow_skipped
    IFS='|' read -r stow_restored stow_failed stow_skipped <<<"${stow_results}"

    echo "" >&2

    # Restore non-stow files second
    local non_stow_results=$(restore_non_stow_files "${backup_dir}" "${manifest_file}" "${dry_run_flag}")
    local non_stow_restored non_stow_failed non_stow_skipped
    IFS='|' read -r non_stow_restored non_stow_failed non_stow_skipped <<<"${non_stow_results}"

    # Calculate totals
    local total_restored=$((stow_restored + non_stow_restored))
    local total_failed=$((stow_failed + non_stow_failed))
    local total_skipped=$((stow_skipped + non_stow_skipped))

    echo "" >&2
    echo "File restoration summary:" >&2
    print_config_item "Stow files restored" "${stow_restored}" >&2
    print_config_item "Non-stow files restored" "${non_stow_restored}" >&2
    print_config_item "Total files restored" "${total_restored}" >&2
    if [[ ${total_failed} -gt 0 ]]; then
        print_config_item "Stow files failed" "${stow_failed}" >&2
        print_config_item "Non-stow files failed" "${non_stow_failed}" >&2
        print_config_item "Total files failed" "${total_failed}" >&2
    fi
    if [[ ${total_skipped} -gt 0 ]]; then
        print_config_item "Stow files skipped" "${stow_skipped}" >&2
        print_config_item "Non-stow files skipped" "${non_stow_skipped}" >&2
        print_config_item "Total files skipped" "${total_skipped}" >&2
    fi
    echo "" >&2

    # Return actual restoration results: stow_restored|stow_failed|stow_skipped|non_stow_restored|non_stow_failed|non_stow_skipped|total_restored|total_failed|total_skipped
    echo "${stow_restored}|${stow_failed}|${stow_skipped}|${non_stow_restored}|${non_stow_failed}|${non_stow_skipped}|${total_restored}|${total_failed}|${total_skipped}"
}

# Function to show backup directory status and cleanup command
show_backup_directory_status() {
    local backup_dir="$1"
    local dry_run_flag="$2"

    # Only show for real mode (not dry-run)
    if [[ ${dry_run_flag} == "dry-run" ]]; then
        return 0
    fi

    echo "Backup directory status:"
    print_config_item "Location" "${backup_dir}"

    # Check if backup directory exists and show contents
    if [[ -d ${backup_dir} ]]; then
        # Count files in stow and non_stow subdirectories
        local stow_files=0
        local non_stow_files=0
        local manifest_files=0

        if [[ -d "${backup_dir}/stow" ]]; then
            stow_files=$(find "${backup_dir}/stow" -type f 2>/dev/null | wc -l | tr -d ' ')
        fi

        if [[ -d "${backup_dir}/non_stow" ]]; then
            non_stow_files=$(find "${backup_dir}/non_stow" -type f 2>/dev/null | wc -l | tr -d ' ')
        fi

        if [[ -f "${backup_dir}/backup-manifest.json" ]]; then
            manifest_files=1
        fi

        local total_dotfiles=$((stow_files + non_stow_files))

        if [[ ${total_dotfiles} -eq 0 ]]; then
            if [[ ${manifest_files} -eq 1 ]]; then
                print_config_item "Remaining files" "(only manifest file - all dotfiles restored)"
            else
                print_config_item "Remaining files" "(empty - all files restored)"
            fi
        else
            print_config_item "Stow files remaining" "${stow_files}"
            print_config_item "Non-stow files remaining" "${non_stow_files}"
            print_config_item "Total files remaining" "${total_dotfiles} (plus manifest)"

            if [[ ${stow_files} -gt 0 ]]; then
                echo ""
                echo "Remaining stow files:"
                find "${backup_dir}/stow" -type f 2>/dev/null | sed "s|${backup_dir}/stow/||" | sort | sed 's/^/  /'
            fi

            if [[ ${non_stow_files} -gt 0 ]]; then
                echo ""
                echo "Remaining non-stow files:"
                find "${backup_dir}/non_stow" -type f 2>/dev/null | sed "s|${backup_dir}/non_stow/||" | sort | sed 's/^/  /'
            fi
        fi

        echo ""
        echo "To clean up the backup directory:"
        echo "  rm -rf \"${backup_dir}\""
    else
        print_config_item "Status" "(directory not found - may have been removed)"
    fi
    echo ""
}

# Function to perform complete restoration
perform_restoration() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    # Step 1: Clean up stow symlinks
    cleanup_stow_symlinks "${dry_run_flag}"

    # Step 2: Restore original files
    local restoration_results=$(restore_files "${backup_dir}" "${manifest_file}" "${dry_run_flag}")

    # Parse restoration results: stow_restored|stow_failed|stow_skipped|non_stow_restored|non_stow_failed|non_stow_skipped|total_restored|total_failed|total_skipped
    local actual_stow_restored actual_stow_failed actual_stow_skipped
    local actual_non_stow_restored actual_non_stow_failed actual_non_stow_skipped
    local actual_total_restored actual_total_failed actual_total_skipped
    IFS='|' read -r actual_stow_restored actual_stow_failed actual_stow_skipped actual_non_stow_restored actual_non_stow_failed actual_non_stow_skipped actual_total_restored actual_total_failed actual_total_skipped <<<"${restoration_results}"

    # Step 3: Final Summary and Completion
    print_step 3 3 "Restoration summary and completion"

    # Show summary
    echo "Summary of restoration operations:"
    echo ""
    print_success "Stow-managed symlinks cleaned up from ${HOME}"
    print_success "Original files restored from backup (${actual_stow_restored} stow + ${actual_non_stow_restored} non-stow = ${actual_total_restored} total files)"
    print_success "Dotfiles restoration completed successfully"
    echo ""
    print_header "Restoration Complete!"
    echo ""

    echo "Operation details:"
    print_config_item "Backup location" "${backup_dir}"
    print_config_item "Stow files restored" "${actual_stow_restored}"
    print_config_item "Non-stow files restored" "${actual_non_stow_restored}"
    print_config_item "Total files restored" "${actual_total_restored}"
    if [[ ${actual_total_failed} -gt 0 ]]; then
        print_config_item "Stow files failed" "${actual_stow_failed}"
        print_config_item "Non-stow files failed" "${actual_non_stow_failed}"
        print_config_item "Total files failed" "${actual_total_failed}"
    fi
    if [[ ${actual_total_skipped} -gt 0 ]]; then
        print_config_item "Stow files skipped" "${actual_stow_skipped}"
        print_config_item "Non-stow files skipped" "${actual_non_stow_skipped}"
        print_config_item "Total files skipped" "${actual_total_skipped}"
    fi
    print_config_item "Stow directory" "${STOW_DIR}"
    echo ""
    echo "Next steps:"
    echo "  • You can now re-run the installation script if desired"
    echo "  • Or keep your restored configuration as-is"
    echo "  • Consider backing up your current state before making changes"
    echo ""

    # Show backup directory status and cleanup command
    show_backup_directory_status "${backup_dir}" "${dry_run_flag}"

    if [[ ${dry_run_flag} == "dry-run" ]]; then
        print_warning "No changes were made to your system - this was a dry run"
    else
        print_warning "The backup directory may now be empty as files were moved back"
    fi
    echo ""

    # Success message last
    if [[ ${dry_run_flag} == "dry-run" ]]; then
        print_preview "Restoration preview completed successfully!"
    else
        print_celebration "Your original dotfiles have been successfully restored!"
    fi
    echo ""
}

# Main execution logic
main() {
    if [[ ${list_backups} -eq 1 ]]; then
        list_available_backups
        return
    fi

    # If no specific backup timestamp provided, show available backups and prompt user
    if [[ -z ${backup_timestamp} ]]; then
        print_header "Disaster Recovery Mode - Restore Original Dotfiles"
        echo ""

        # shellcheck disable=SC2310
        if ! list_available_backups; then
            die "ERROR: No backups available for restoration"
        fi

        echo -n "Enter the timestamp of the backup you want to restore (or 'q' to quit): "
        read -r user_choice

        if [[ ${user_choice} == "q" || ${user_choice} == "Q" ]]; then
            echo "Restoration cancelled."
            exit 0
        fi
        echo ""

        backup_timestamp="${user_choice}"
    fi

    # Validate timestamp format
    validate_backup_timestamp "${backup_timestamp}"

    # Get and validate backup directory
    local backup_dir=$(get_backup_dir_by_timestamp "${backup_timestamp}")
    local manifest_file=$(validate_backup_directory "${backup_dir}")

    # Show configuration details
    local backup_date=$(get_backup_metadata "${manifest_file}" "date")
    local stow_count=$(get_stow_file_count "${manifest_file}")
    local non_stow_count=$(get_non_stow_file_count "${manifest_file}")
    local total_count=$(get_total_file_count "${manifest_file}")

    print_header "Dotfiles Restoration Process"
    echo ""
    print_subheader "Configuration"
    print_config_item "Stow directory" "${STOW_DIR}"
    print_config_item "Backup timestamp" "${backup_timestamp}"
    print_config_item "Backup date" "${backup_date}"
    print_config_item "Stow files to restore" "${stow_count}"
    print_config_item "Non-stow files to restore" "${non_stow_count}"
    print_config_item "Total files to restore" "${total_count}"
    print_config_item "Backup location" "${backup_dir}"
    print_config_item "Dry run mode" "$(if [[ ${dry_run} -eq 1 ]]; then echo "Yes (preview only)"; else echo "No (actual restoration)"; fi)"
    echo ""

    # Show warning about what will happen
    print_warning "This will restore your original dotfiles and remove any stow-managed symlinks."
    if [[ ${dry_run} -eq 1 ]]; then
        print_warning "This is a preview mode - no changes will be made to your system"
    fi
    echo ""

    # Get user confirmation for real mode
    if [[ ${dry_run} -eq 0 ]]; then
        echo -n "Are you sure you want to continue? (y/N): "
        read -r confirmation

        if [[ ! ${confirmation} =~ ^[Yy]$ ]]; then
            echo "Restoration cancelled."
            exit 0
        fi
        echo ""
    fi

    # Execute restoration
    perform_restoration "${backup_dir}" "${manifest_file}" "$(if [[ ${dry_run} -eq 1 ]]; then echo "dry-run"; else echo "real"; fi)"
}

# Run main function
main "$@"
