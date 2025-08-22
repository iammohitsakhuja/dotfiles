#!/usr/bin/env bash

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

    echo "Available backups:"
    echo "=================="

    for backup_dir in "${backup_dirs[@]}"; do
        [[ -z ${backup_dir} ]] && continue
        local timestamp=$(basename "${backup_dir}")
        local manifest_file=$(get_manifest_file_path "${backup_dir}")

        if [[ -f ${manifest_file} ]]; then
            # Extract backup date and file count from JSON
            local backup_date=$(get_backup_metadata "${manifest_file}" "date")
            local file_count=$(get_backup_metadata "${manifest_file}" "file_count")

            echo "  ${timestamp} (${file_count} files backed up)"
            echo "    Date: ${backup_date}"
            echo "    Location: ${backup_dir}"
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
        stow -n -D -d "${STOW_DIR}" -t "${HOME}" home --verbose=2
        local exit_code=$?
    else
        # Execute actual stow removal - show all output
        stow -D -d "${STOW_DIR}" -t "${HOME}" home --verbose=2
        local exit_code=$?
    fi

    if [[ ${exit_code} -eq 0 ]]; then
        print_success "Stow symlinks cleaned up successfully"
    else
        print_warning "Some stow operations could not be completed (this may be normal if installation was incomplete)"
    fi
    echo ""
}

# Function to restore files from backup
restore_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    print_step 2 3 "Restoring original files from backup"

    local files_to_restore=$(get_backed_up_files "${manifest_file}")
    if [[ -z ${files_to_restore} ]]; then
        print_warning "No files to restore from this backup"
        return 0
    fi

    local files_restored=0
    local files_failed=0

    while IFS= read -r relative_path; do
        [[ -z ${relative_path} ]] && continue

        local backup_file="${backup_dir}/${relative_path}"
        local target_file="${HOME}/${relative_path}"

        # Validate paths are safe
        if [[ ${relative_path} =~ ^/ ]] || [[ ${relative_path} =~ \.\. ]]; then
            print_warning "Unsafe path detected, skipping: ${relative_path}"
            ((files_failed++))
            continue
        fi

        # Check if backup file exists
        if [[ ! -f ${backup_file} ]]; then
            print_warning "Backup file not found, skipping: ${relative_path}"
            ((files_failed++))
            continue
        fi

        # Show what file will be restored
        print_action "Restoring: ${relative_path}"
        echo "    From: ${backup_file}"
        echo "    To: ${target_file}"

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
                print_warning "Target file already exists: ${relative_path}"
                echo "  Choose action: (r)eplace, (s)kip, (q)uit"
                read -r action
                case "${action}" in
                r | R | replace)
                    print_action "Replacing existing file..."
                    ;;
                s | S | skip)
                    print_action "Skipping file..."
                    continue
                    ;;
                q | Q | quit)
                    echo "Restoration cancelled by user."
                    exit 0
                    ;;
                *)
                    print_action "Invalid choice, skipping file..."
                    continue
                    ;;
                esac
            fi

            # Move file back from backup (atomic operation - reverse of backup)
            if mv "${backup_file}" "${target_file}" 2>/dev/null; then
                print_success "Restored: ${relative_path}"
                ((files_restored++))
            else
                print_warning "Failed to restore: ${relative_path}"
                ((files_failed++))
            fi
        fi
    done <<<"${files_to_restore}"

    echo ""
    echo "File restoration summary:"
    print_config_item "Files restored" "${files_restored}"
    if [[ ${files_failed} -gt 0 ]]; then
        print_config_item "Files failed" "${files_failed}"
    fi
    echo ""
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
        # Count dotfiles (excluding manifest) and total files
        local dotfile_count=$(find "${backup_dir}" -type f ! -name "backup-manifest.json" 2>/dev/null | wc -l)
        local total_files=$(find "${backup_dir}" -type f 2>/dev/null | wc -l)

        if [[ ${dotfile_count} -eq 0 ]]; then
            if [[ ${total_files} -eq 1 ]]; then
                print_config_item "Remaining files" "(only manifest file - all dotfiles restored)"
            elif [[ ${total_files} -eq 0 ]]; then
                print_config_item "Remaining files" "(empty - all files restored)"
            else
                print_config_item "Remaining files" "(all dotfiles restored, ${total_files} metadata files remain)"
            fi
        else
            print_config_item "Remaining files" "${dotfile_count} dotfiles (plus manifest)"
            echo ""
            echo "Remaining dotfiles in backup directory:"
            find "${backup_dir}" -type f ! -name "backup-manifest.json" -exec basename {} \; 2>/dev/null | sort | sed 's/^/  /'
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
    restore_files "${backup_dir}" "${manifest_file}" "${dry_run_flag}"

    # Step 3: Final Summary and Completion
    print_step 3 3 "Restoration summary and completion"

    # Show summary
    echo "Summary of restoration operations:"
    echo ""
    print_success "Stow-managed symlinks cleaned up from ${HOME}"
    local file_count=$(get_backup_metadata "${manifest_file}" "file_count")
    print_success "Original files restored from backup (${file_count} files)"
    print_success "Dotfiles restoration completed successfully"
    echo ""
    print_header "Restoration Complete!"
    echo ""

    if [[ ${dry_run_flag} == "dry-run" ]]; then
        print_preview "Restoration preview completed successfully!"
        echo ""
        print_warning "No changes were made to your system - this was a dry run"
    else
        print_celebration "Your original dotfiles have been successfully restored!"
        echo ""
        print_warning "The backup directory may now be empty as files were moved back"
    fi

    echo ""
    echo "Operation details:"
    print_config_item "Backup location" "${backup_dir}"
    print_config_item "Files restored" "${file_count}"
    print_config_item "Stow directory" "${STOW_DIR}"
    echo ""
    echo "Next steps:"
    echo "  • You can now re-run the installation script if desired"
    echo "  • Or keep your restored configuration as-is"
    echo "  • Consider backing up your current state before making changes"
    echo ""

    # Show backup directory status and cleanup command
    show_backup_directory_status "${backup_dir}" "${dry_run_flag}"
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

        if ! list_available_backups; then
            die "ERROR: No backups available for restoration"
        fi

        echo "Enter the timestamp of the backup you want to restore (or 'q' to quit):"
        read -r user_choice

        if [[ ${user_choice} == "q" || ${user_choice} == "Q" ]]; then
            echo "Restoration cancelled."
            exit 0
        fi

        backup_timestamp="${user_choice}"
    fi

    # Validate timestamp format
    validate_backup_timestamp "${backup_timestamp}"

    # Get and validate backup directory
    local backup_dir=$(get_backup_dir_by_timestamp "${backup_timestamp}")
    local manifest_file=$(validate_backup_directory "${backup_dir}")

    # Show configuration details
    local backup_date=$(get_backup_metadata "${manifest_file}" "date")
    local file_count=$(get_backup_metadata "${manifest_file}" "file_count")

    print_header "Dotfiles Restoration Process"
    echo ""
    echo "Configuration:"
    print_config_item "Stow directory" "${STOW_DIR}"
    print_config_item "Backup timestamp" "${backup_timestamp}"
    print_config_item "Backup date" "${backup_date}"
    print_config_item "Files to restore" "${file_count}"
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
        echo "Are you sure you want to continue? (y/N)"
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
