#!/usr/bin/env bash

# Enable strict error handling
set -e          # Exit on any command failure
set -o pipefail # Fail on any command in a pipeline

# Source shared utilities
source "$(dirname "$0")/utils/logging.sh"
source "$(dirname "$0")/utils/backup.sh"

# Get the stow directory (directory containing this script).
STOW_DIR=$(cd "$(dirname "$0")" && pwd)

# Actual backup directory path (set by backup function)
BACKUP_DIR=""

# Initialise the option variables.
# This ensures we are not contaminated by variables from the environment.
backup=1 # 0 is for no backup, 1 is for backup (default).
email=
name=

# TODO: Add a verbose option.
show_help() {
    echo "Usage: ./install.sh [-h | --help] [--no-backup] [-e | --email] [-n | --name]"
    echo "       -h, --help     | Show this help."
    echo "       --no-backup    | Skip backing up existing files before stow operations."
    echo '       -e, --email    | The email that you would like to use for setting up things like git, ssh e.g. "abc@example.com".'
    echo '       -n, --name     | The name that you would like to use for setting up things like git e.g. "John Doe".'
    echo ""
}

# Ensure proper usage.
while :; do
    case $1 in
    -h | -\? | --help)
        show_help
        exit
        ;;
    --no-backup)
        backup=0
        shift
        ;;
    -e | --email)
        # TODO: Handle the case where the next argument to email is another option e.g. `-e -c`.
        if [[ -n $2 ]]; then
            email=$2
            shift 2
        else
            die 'ERROR: "--email" requires a non-empty option argument.'
        fi
        ;;
    --email=?*)
        email=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --email=) # Handle the case of an empty --email=.
        die 'ERROR: "--email" requires a non-empty option argument.'
        ;;
    -n | --name)
        # TODO: Handle the case where the next argument to name is another option e.g. `-n -c`.
        if [[ -n $2 ]]; then
            name=$2
            shift 2
        else
            die 'ERROR: "--name" requires a non-empty option argument.'
        fi
        ;;
    --name=?*)
        name=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --name=) # Handle the case of an empty --name=.
        die 'ERROR: "--name" requires a non-empty option argument.'
        ;;
    *) # Default case: No more options, so break out of the loop.
        print_header "macOS Dotfiles Installation"
        echo ""
        echo "Configuration:"
        print_config_item "Backup existing files" "$(if [[ ${backup} == 1 ]]; then echo "Yes"; else echo "No"; fi)"
        print_config_item "Email" "${email}"
        print_config_item "Name" "${name}"
        print_config_item "Stow directory" "${STOW_DIR}"
        echo ""

        # Argument Validations.
        if [[ -z ${email} ]]; then
            die 'ERROR: "--email" is required.'
        fi
        if [[ -z ${name} ]]; then
            die 'ERROR: "--name" is required.'
        fi
        break
        ;;
    esac
done

# Other Validations.
# Validate we found the correct directory with home/ package
if [[ ! -d "${STOW_DIR}/home" ]]; then
    die "ERROR: Could not locate home/ directory for stow operations."
fi

print_header "Authentication & Dependencies"
echo ""

# Ask for administrator password upfront.
print_action "Requesting administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

print_success "Administrator authentication confirmed"
echo ""

# Function to install essential dependencies needed for the installation
bootstrap_dependencies() {
    print_step 1 5 "Checking and installing essential dependencies"
    echo ""

    # Check if we're on macOS
    if [[ ${OSTYPE} != "darwin"* ]]; then
        die "ERROR: This script is designed for macOS only"
    fi
    print_success "macOS environment confirmed"

    # Install Rosetta 2.
    print_action "Installing Rosetta 2 for Apple Silicon Mac..."
    if sudo softwareupdate --install-rosetta --agree-to-license 2>/dev/null; then
        print_success "Rosetta 2 installation completed"
    else
        print_success "Rosetta 2 already installed or installation skipped"
    fi

    # Install Command Line Tools if not present (avoids popup)
    if ! xcode-select -p >/dev/null 2>&1; then
        print_action "Installing Xcode Command Line Tools..."
        # Create a temporary file to trigger automatic installation
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        # Find the latest Command Line Tools package
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -1 | sed 's/^[^C]* //')
        if [[ -n ${PROD} ]]; then
            softwareupdate -i "${PROD}" --verbose
        else
            # Fallback method if softwareupdate doesn't list CLT
            xcode-select --install
            echo "    Please wait for Command Line Tools installation to complete..."
            until xcode-select -p >/dev/null 2>&1; do
                sleep 5
            done
        fi
        # Clean up the trigger file
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        print_success "Command Line Tools installation completed"
    else
        print_success "Command Line Tools already installed"
    fi

    # Install Homebrew if it isn't installed already
    if ! command -v brew >/dev/null 2>&1; then
        print_action "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Evaluate homebrew correctly for the current session on Apple Silicon Mac.
        eval "$(/opt/homebrew/bin/brew shellenv)"
        print_success "Homebrew installation completed"
    else
        print_success "Homebrew already installed"
    fi

    # Install GNU Stow if not available
    if ! command -v stow >/dev/null 2>&1; then
        print_action "Installing GNU Stow..."
        brew install stow
        print_success "GNU Stow installation completed"
    else
        print_success "GNU Stow already installed"
    fi

    # Install jq for JSON processing if not available
    if ! command -v jq >/dev/null 2>&1; then
        print_action "Installing jq for JSON processing..."
        brew install jq
        print_success "jq installation completed"
    else
        print_success "jq already installed"
    fi

    echo ""
    print_success "Essential dependencies are ready!"
    echo ""
}

# Install essential dependencies before proceeding
bootstrap_dependencies

print_header "Backup & File Management"
echo ""

# Function to backup existing files before stow operations
backup_existing_files() {
    if [[ ${backup} == 0 ]]; then
        echo "Skipping backup as requested..."
        return 0
    fi

    echo "Checking for existing files that would be overwritten..."

    # Create timestamped backup directory
    local backup_timestamp=$(generate_backup_timestamp)
    local backup_dir=$(get_backup_dir_by_timestamp "${backup_timestamp}")
    local manifest_file=$(get_manifest_file_path "${backup_dir}")

    # Use stow simulation with verbose output to detect actual conflicts
    local stow_output=$(stow -n -d "${STOW_DIR}" -t "${HOME}" home --verbose=3 2>&1)

    # Filter files that are causing conflicts - catch both types of conflicts
    local stowing_conflicts=$(echo "${stow_output}" | grep "CONFLICT when stowing" | sed -n 's/.*over existing target \([^[:space:]]*\).*/\1/p')
    local ownership_conflicts=$(echo "${stow_output}" | grep "CONFLICT when stowing" | sed -n 's/.*existing target is not owned by stow: \([^[:space:]]*\).*/\1/p')

    # Combine both types of conflicts
    local actual_conflicts=$(printf "%s\n%s" "${stowing_conflicts}" "${ownership_conflicts}" | grep -v '^$' | sort -u)

    if [[ -z ${actual_conflicts} ]]; then
        echo "No existing files would be overwritten. Proceeding without backup."
        return 0
    fi

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
    echo "Creating backup directory: ${backup_dir}"
    ensure_backup_structure "${backup_dir}"
    echo "Manifest file path: ${manifest_file}"

    # Show conflict summary to user
    local stowing_count=$(echo "${stowing_conflicts}" | grep -c . 2>/dev/null || echo 0)
    local ownership_count=$(echo "${ownership_conflicts}" | grep -c . 2>/dev/null || echo 0)
    echo "Found conflicts: ${stowing_count} stowing conflicts, ${ownership_count} ownership conflicts"

    # Initialize JSON manifest file
    local backup_date=$(date -Iseconds)
    local stowing_conflicts_json
    local ownership_conflicts_json

    # Convert conflicts to JSON arrays
    if [[ -n ${stowing_conflicts} ]]; then
        stowing_conflicts_json=$(echo "${stowing_conflicts}" | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        stowing_conflicts_json="[]"
    fi

    if [[ -n ${ownership_conflicts} ]]; then
        ownership_conflicts_json=$(echo "${ownership_conflicts}" | jq -R -s 'split("\n") | map(select(length > 0))')
    else
        ownership_conflicts_json="[]"
    fi

    local total_conflicts=$(echo "${actual_conflicts}" | grep -c . 2>/dev/null || echo 0)

    # Create initial JSON structure
    cat >"${manifest_file}" <<EOF
{
  "metadata": {
    "backup_date": "${backup_date}",
    "repository_path": "${STOW_DIR}",
    "backup_version": "1.0"
  },
  "conflicts": {
    "stowing_conflicts": ${stowing_conflicts_json},
    "ownership_conflicts": ${ownership_conflicts_json},
    "total_count": ${total_conflicts}
  },
  "files": [],
  "summary": {
    "files_backed_up": 0,
    "files_failed": 0,
    "backup_size_total": 0
  }
}
EOF

    local files_backed_up=0
    local files_failed=0
    local total_backup_size=0

    # Helper function to add file entry to JSON manifest
    add_file_to_manifest() {
        local file_path="$1"
        local status="$2"
        local conflict_type="$3"
        local file_size="$4"

        # Create temporary file with new entry
        local temp_manifest=$(mktemp)
        jq --arg path "${file_path}" --arg status "${status}" --arg type "${conflict_type}" --argjson size "${file_size}" \
            '.files += [{"path": $path, "status": $status, "conflict_type": $type, "backup_size": $size}]' \
            "${manifest_file}" >"${temp_manifest}"
        mv "${temp_manifest}" "${manifest_file}"
    }

    # Helper function to update manifest summary
    update_manifest_summary() {
        local temp_manifest=$(mktemp)
        jq --argjson backed_up "${files_backed_up}" --argjson failed "${files_failed}" --argjson total_size "${total_backup_size}" \
            '.summary.files_backed_up = $backed_up | .summary.files_failed = $failed | .summary.backup_size_total = $total_size' \
            "${manifest_file}" >"${temp_manifest}"
        mv "${temp_manifest}" "${manifest_file}"
    }

    # Backup all conflicting files.
    for relative_path in ${actual_conflicts}; do
        # Validate paths are relative and safe
        if [[ ${relative_path} =~ ^/ ]] || [[ ${relative_path} =~ \.\. ]]; then
            echo "WARNING: Unsafe path detected: ${relative_path}"
            add_file_to_manifest "${relative_path}" "unsafe_path" "unknown" 0
            ((files_failed++))
            continue
        fi

        local target_file="${HOME}/${relative_path}"

        # Determine conflict type
        local conflict_type="unknown"
        if echo "${stowing_conflicts}" | grep -q "^${relative_path}$"; then
            conflict_type="stowing"
        elif echo "${ownership_conflicts}" | grep -q "^${relative_path}$"; then
            conflict_type="ownership"
        fi

        # Check if target file exists
        if [[ -e ${target_file} ]]; then
            # Get file size
            local file_size
            if [[ -f ${target_file} ]]; then
                file_size=$(stat -f%z "${target_file}" 2>/dev/null || echo 0)
            else
                file_size=0
            fi

            # File exists and would conflict, backup it
            local backup_file="${backup_dir}/${relative_path}"
            local backup_parent_dir=$(dirname "${backup_file}")

            mkdir -p "${backup_parent_dir}"

            # Move file to backup location (atomic operation)
            if mv "${target_file}" "${backup_file}" 2>/dev/null; then
                add_file_to_manifest "${relative_path}" "moved_successfully" "${conflict_type}" "${file_size}"
                echo "Moved to backup: ${relative_path}"
                ((files_backed_up++))
                ((total_backup_size += file_size))
            else
                add_file_to_manifest "${relative_path}" "move_failed" "${conflict_type}" 0
                ((files_failed++))
                die "ERROR: Failed to move ${relative_path} to backup - check permissions"
            fi
        else
            add_file_to_manifest "${relative_path}" "target_missing" "${conflict_type}" 0
            ((files_failed++))
            die "ERROR: Conflict file ${relative_path} doesn't exist at target"
        fi
    done

    # Update final summary in manifest
    update_manifest_summary

    if [[ ${files_backed_up} -gt 0 ]]; then
        # Store the backup directory for summary display
        BACKUP_DIR="${backup_dir}"
        echo ""
        echo "Backup completed successfully!"
        echo "  Location: ${backup_dir}"
        echo "  Files backed up: ${files_backed_up}"
        echo "  Manifest: ${manifest_file}"
        echo ""
    else
        # Remove empty backup directory if no files were actually backed up
        cleanup_empty_backup_dir "${backup_dir}"
        echo "No files needed backup. Proceeding with installation."
        echo ""
    fi

    return 0
}

# Backup existing files before stow operations
print_step 2 5 "Backing up existing files and linking dotfiles"
backup_existing_files

# Stow will handle all dotfile symlinking.
# The home/ directory structure mirrors the $HOME directory structure
echo "Linking dotfiles into ${HOME}/ using stow..."
stow -d "${STOW_DIR}" -t "${HOME}" home --verbose=1
print_success "Dotfiles linked successfully!"
echo ""

print_header "System Configuration"
echo ""

# Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
print_step 3 5 "Configuring system authentication and user settings"
echo ""
print_action "Configuring Touch ID for sudo authentication on Apple Silicon Mac with compatible hardware..."
# Check if Touch ID line already exists to avoid duplicates
if ! sudo grep -q "pam_tid.so" /etc/pam.d/sudo; then
    # Backup the original file before modifying
    sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
    # This syntax is required to work properly with macOS's inbuilt version of `sed`
    sudo sed -i '' '3i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
    print_success "Touch ID authentication enabled for sudo commands"
else
    print_success "Touch ID authentication already configured"
fi

# File to store any API keys in.
print_action "Creating API keys storage file..."
touch ~/.api_keys
print_success "API keys file created at ~/.api_keys"

# Configure git.
print_action "Configuring Git with provided credentials..."
git config --global user.email "${email}"
git config --global user.name "${name}"
git config --global core.editor "nvim"
git config --global core.filemode false
git config --global status.showuntrackedfiles all
git config --global status.submodulessummary 1
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global merge.conflictstyle "zdiff3"
git config --global color.ui true

# Include delta configuration from separate file.
git config --global include.path "${HOME}/.gitconfig-delta"
print_success "Git configuration completed"

# Create SSH key pair.
print_action "Generating SSH key pair..."

# Check if SSH keys already exist
if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
    print_success "SSH key already exists at ${HOME}/.ssh/id_ed25519"
    echo "    Skipping key generation to avoid overwriting existing key"
else
    # Generate SSH key non-interactively
    ssh-keygen -t ed25519 -C "${email}" -f "${HOME}/.ssh/id_ed25519" -N "" -q

    # Verify SSH key generation was successful
    if [[ -f "${HOME}/.ssh/id_ed25519" && -f "${HOME}/.ssh/id_ed25519.pub" ]]; then
        print_success "SSH key pair generated successfully"

        # Verify SSH directory permissions
        ssh_dir_perms=$(stat -f "%A" "${HOME}/.ssh" 2>/dev/null || echo "unknown")
        if [[ ${ssh_dir_perms} == "700" ]]; then
            print_success "SSH directory permissions are correct (700)"
        else
            print_warning "SSH directory permissions may need adjustment"
            echo "    Expected: 700, Current: ${ssh_dir_perms}"
        fi
    else
        die "ERROR: SSH key generation failed - key files not found"
    fi
fi
echo ""

print_header "Package Installation & Setup"
echo ""

# Run installation scripts.
print_step 4 5 "Installing packages and configuring system components"
echo ""

print_action "Installing Homebrew packages and development tools..."
bash "${STOW_DIR}/scripts/packages.sh"
print_success "All packages installed successfully"
echo ""

# Configure Tmux colors.
print_action "Configuring Tmux terminal colors..."
tic -x "${STOW_DIR}/utils/terminfo/xterm-256color-italic.terminfo"
tic -x "${STOW_DIR}/utils/terminfo/tmux-256color.terminfo"
print_success "Tmux terminal colors configured"
echo ""

# Configure MacOS settings.
print_action "Applying macOS system preferences and settings..."
bash "${STOW_DIR}/scripts/macos.sh"
print_success "macOS system settings configured"
echo ""

print_header "Installation Complete!"
echo ""
print_step 5 5 "Summary of completed installation"
echo ""
print_success "Essential dependencies installed (Homebrew, Stow, Command Line Tools)"
if [[ ${backup} == 1 ]]; then
    print_success "Existing dotfiles backed up (if any conflicts found)"
else
    print_success "Backup skipped as requested"
fi
print_success "Dotfiles linked to home directory"
print_success "Touch ID configured for sudo authentication"
print_success "Git configured with user credentials (${name} <${email}>)"
print_success "SSH key pair generated (if not already present)"
print_success "API keys storage file created"
print_success "Development packages and tools installed"
print_success "Terminal colors configured for Tmux"
print_success "macOS system preferences applied"
echo ""
print_celebration "Your macOS development environment is now ready!"
echo ""
echo "Next steps:"
echo "  • Add your SSH public key to GitHub/GitLab"
echo "  • Restart your terminal or run 'source ~/.zshrc'"
echo "  • Review installed applications and configure as needed"
echo ""
echo "SSH public key location: ${HOME}/.ssh/id_ed25519.pub"
if [[ -n ${BACKUP_DIR} ]]; then
    echo "Dotfiles backup location: ${BACKUP_DIR}"
else
    echo "Dotfiles backup location: No backup created"
fi
echo ""
echo "======================================================================"
