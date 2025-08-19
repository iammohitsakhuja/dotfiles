#!/usr/bin/env bash

# Helper function to exit the script.
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize option variables.
list_backups=0
backup_timestamp=""
dry_run=0
help=0

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
        if [[ "$2" ]]; then
            backup_timestamp="$2"
            shift 2
        else
            die "ERROR: \"--backup\" requires a non-empty option argument."
        fi
        ;;
    --backup=?*)
        backup_timestamp=${1#*=}
        shift
        ;;
    --backup=)
        die "ERROR: \"--backup\" requires a non-empty option argument."
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

# Get the current working directory (should be the dotfiles repo).
REPO_DIR=$(pwd)

# Validate we're in a dotfiles repository
if [[ ! -f "$REPO_DIR/macos/install.sh" ]]; then
    die "ERROR: This script must be run from the dotfiles repository root directory"
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
    local backup_pattern="$HOME/.dotfiles-backup-*"
    local backup_dirs=()

    # Find backup directories and sort them (newest first)
    while IFS= read -r -d '' dir; do
        backup_dirs+=("$dir")
    done < <(find "$HOME" -maxdepth 1 -name ".dotfiles-backup-*" -type d -print0 2>/dev/null | sort -rz)

    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        echo "No backup directories found in $HOME"
        return 1
    fi

    echo "Available backups:"
    echo "=================="

    for backup_dir in "${backup_dirs[@]}"; do
        local timestamp=$(basename "$backup_dir" | sed 's/^\.dotfiles-backup-//')
        local manifest_file="$backup_dir/backup-manifest.json"

        if [[ -f "$manifest_file" ]]; then
            local backup_date
            local file_count

            # Extract backup date and file count from JSON
            backup_date=$(jq -r '.metadata.backup_date' "$manifest_file" 2>/dev/null || echo "Unknown")
            file_count=$(jq -r '.summary.files_backed_up' "$manifest_file" 2>/dev/null || echo "0")

            echo "  $timestamp ($file_count files backed up)"
            echo "    Date: $backup_date"
            echo "    Location: $backup_dir"
        else
            echo "  $timestamp (manifest file missing - backup may be incomplete)"
        fi
        echo ""
    done

    return 0
}

# Function to validate backup timestamp format
validate_timestamp() {
    local timestamp="$1"

    if [[ ! "$timestamp" =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
        die "ERROR: Invalid timestamp format. Expected YYYYMMDD-HHMMSS (e.g., 20250811-143022)"
    fi
}

# Function to get backup directory path from timestamp
get_backup_dir() {
    local timestamp="$1"
    echo "$HOME/.dotfiles-backup-$timestamp"
}

# Function to validate backup directory and manifest
validate_backup() {
    local backup_dir="$1"
    local manifest_file="$backup_dir/backup-manifest.json"

    if [[ ! -d "$backup_dir" ]]; then
        die "ERROR: Backup directory not found: $backup_dir"
    fi

    if [[ ! -f "$manifest_file" ]]; then
        die "ERROR: Backup manifest file not found: $manifest_file"
    fi

    # Validate JSON format
    if ! jq empty "$manifest_file" 2>/dev/null; then
        die "ERROR: Invalid JSON format in manifest file"
    fi

    # Check if any files were successfully backed up
    local backed_up_count
    backed_up_count=$(jq -r '.summary.files_backed_up' "$manifest_file" 2>/dev/null || echo "0")
    if [[ "$backed_up_count" -eq 0 ]]; then
        die "ERROR: No successfully backed up files found in manifest"
    fi

    echo "$manifest_file"
}

# Function to clean up stow-managed symlinks
cleanup_stow_symlinks() {
    local dry_run_flag="$1"

    echo "Step 1: Cleaning up stow-managed symlinks..."
    echo "============================================"

    if [[ "$dry_run_flag" == "dry-run" ]]; then
        echo "[DRY RUN] Would execute: stow -D -d '$REPO_DIR' -t '$HOME' home --verbose=2"
        echo "[DRY RUN] This would remove symlinks created by previous stow operations"
    else
        # Use stow to properly remove all symlinks from the home directory
        echo "Removing stow-managed symlinks from $HOME..."
        if stow -D -d "$REPO_DIR" -t "$HOME" home --verbose=2 2>/dev/null; then
            echo "✓ Stow symlinks cleaned up successfully"
        else
            echo "⚠ Warning: Some stow symlinks could not be removed (this may be normal if installation was incomplete)"
        fi
    fi
    echo ""
}

# Function to get list of files to restore from manifest
get_files_to_restore() {
    local manifest_file="$1"

    # Extract files that were successfully moved to backup
    jq -r '.files[] | select(.status == "moved_successfully") | .path' "$manifest_file"
}

# Function to restore files from backup
restore_files() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    echo "Step 2: Restoring original files..."
    echo "==================================="

    local files_to_restore
    files_to_restore=$(get_files_to_restore "$manifest_file")

    if [[ -z "$files_to_restore" ]]; then
        echo "No files to restore from this backup."
        return 0
    fi

    local files_restored=0
    local files_failed=0

    while IFS= read -r relative_path; do
        [[ -z "$relative_path" ]] && continue

        local backup_file="$backup_dir/$relative_path"
        local target_file="$HOME/$relative_path"

        # Validate paths are safe
        if [[ "$relative_path" =~ ^/ ]] || [[ "$relative_path" =~ \.\. ]]; then
            echo "⚠ Warning: Unsafe path detected, skipping: $relative_path"
            ((files_failed++))
            continue
        fi

        # Check if backup file exists
        if [[ ! -f "$backup_file" ]]; then
            echo "⚠ Warning: Backup file not found, skipping: $relative_path"
            ((files_failed++))
            continue
        fi

        if [[ "$dry_run_flag" == "dry-run" ]]; then
            echo "[DRY RUN] Would restore: $relative_path"
            echo "[DRY RUN]   From: $backup_file"
            echo "[DRY RUN]   To: $target_file"
            ((files_restored++))
        else
            # Create target directory if it doesn't exist
            local target_dir
            target_dir=$(dirname "$target_file")
            if [[ ! -d "$target_dir" ]]; then
                mkdir -p "$target_dir"
            fi

            # Check if target file already exists
            if [[ -e "$target_file" ]]; then
                echo "⚠ Warning: Target file already exists: $relative_path"
                echo "  Choose action: (r)eplace, (s)kip, (q)uit"
                read -r action
                case "$action" in
                    r|R|replace)
                        echo "  Replacing existing file..."
                        ;;
                    s|S|skip)
                        echo "  Skipping file..."
                        continue
                        ;;
                    q|Q|quit)
                        echo "Restoration cancelled by user."
                        exit 0
                        ;;
                    *)
                        echo "  Invalid choice, skipping file..."
                        continue
                        ;;
                esac
            fi

            # Move file back from backup (atomic operation - reverse of backup)
            if mv "$backup_file" "$target_file" 2>/dev/null; then
                echo "✓ Restored: $relative_path"
                ((files_restored++))
            else
                echo "✗ Failed to restore: $relative_path"
                ((files_failed++))
            fi
        fi
    done <<< "$files_to_restore"

    echo ""
    echo "Restoration summary:"
    echo "  Files restored: $files_restored"
    if [[ $files_failed -gt 0 ]]; then
        echo "  Files failed: $files_failed"
    fi
    echo ""
}

# Function to perform complete restoration
perform_restoration() {
    local backup_dir="$1"
    local manifest_file="$2"
    local dry_run_flag="$3"

    echo "Starting restoration process..."
    echo ""

    # Step 1: Clean up stow symlinks
    cleanup_stow_symlinks "$dry_run_flag"

    # Step 2: Restore original files
    restore_files "$backup_dir" "$manifest_file" "$dry_run_flag"

    if [[ "$dry_run_flag" != "dry-run" ]]; then
        echo "Restoration completed successfully!"
        echo ""
        echo "Your original dotfiles have been moved back from backup."
        echo "Note: The backup directory may now be empty as files were moved"
        echo "back to their original locations at: $backup_dir"
        echo ""
        echo "You can now re-run the installation script if desired, or keep"
        echo "your restored configuration as-is."
    else
        echo "Dry run completed. No changes were made to your system."
    fi
}

# Main execution logic
main() {
    if [[ $list_backups -eq 1 ]]; then
        list_available_backups
        return
    fi

    # If no specific backup timestamp provided, show available backups and prompt user
    if [[ -z "$backup_timestamp" ]]; then
        echo "Disaster Recovery Mode - Restore Original Dotfiles"
        echo "================================================="
        echo ""

        if ! list_available_backups; then
            die "ERROR: No backups available for restoration"
        fi

        echo "Enter the timestamp of the backup you want to restore (or 'q' to quit):"
        read -r user_choice

        if [[ "$user_choice" == "q" || "$user_choice" == "Q" ]]; then
            echo "Restoration cancelled."
            exit 0
        fi

        backup_timestamp="$user_choice"
    fi

    # Validate timestamp format
    validate_timestamp "$backup_timestamp"

    # Get and validate backup directory
    local backup_dir
    backup_dir=$(get_backup_dir "$backup_timestamp")
    local manifest_file
    manifest_file=$(validate_backup "$backup_dir")

    # Show backup details
    local backup_date=$(jq -r '.metadata.backup_date' "$manifest_file" 2>/dev/null || echo "Unknown")
    local file_count=$(jq -r '.summary.files_backed_up' "$manifest_file" 2>/dev/null || echo "0")

    echo "Preparing to restore from backup: $backup_timestamp"
    echo "Backup details:"
    echo "  Date: $backup_date"
    echo "  Files to restore: $file_count"
    echo "  Location: $backup_dir"
    echo ""

    if [[ $dry_run -eq 1 ]]; then
        echo "DRY RUN MODE - No changes will be made"
        echo "====================================="
        echo ""
        perform_restoration "$backup_dir" "$manifest_file" "dry-run"
    else
        echo "WARNING: This will restore your original dotfiles and remove any stow-managed symlinks."
        echo "Are you sure you want to continue? (y/N)"
        read -r confirmation

        if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
            echo "Restoration cancelled."
            exit 0
        fi
        echo ""

        perform_restoration "$backup_dir" "$manifest_file" "real"
    fi
}

# Run main function
main "$@"
