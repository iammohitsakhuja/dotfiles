#!/usr/bin/env bash

# Enable strict error handling
set -e          # Exit on any command failure
set -o pipefail # Fail on any command in a pipeline

# Source shared utilities
source "$(dirname "$0")/utils/logging.sh"
source "$(dirname "$0")/utils/miscellaneous.sh"
source "$(dirname "$0")/utils/platform.sh"
source "$(dirname "$0")/utils/backup.sh"
source "$(dirname "$0")/utils/bootstrap.sh"

# Require Apple Silicon Mac - fail immediately if not supported
require_apple_silicon

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
        print_subheader "Configuration:"
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

# Keep sudo alive with proper cleanup, i.e., update existing time stamp until `./install.sh` has finished.
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

# Start the keepalive
sudo_keepalive

print_success "Administrator authentication confirmed"
echo ""

# Install essential dependencies before proceeding
bootstrap_dependencies

print_header "Backup & File Management"
echo ""

# Backup existing files before stow operations
print_step 2 5 "Backing up existing files and linking dotfiles"
BACKUP_DIR=$(backup_existing_files "${backup}" "${STOW_DIR}")

# Stow will handle all dotfile symlinking.
# The home/ directory structure mirrors the $HOME directory structure.
# Do not fold the tree.
echo "Linking dotfiles into ${HOME}/ using stow..."
stow -d "${STOW_DIR}" -t "${HOME}" --no-folding home --verbose=1
print_success "Dotfiles linked successfully!"
echo ""

print_header "System Configuration"
echo ""

# Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
print_step 3 5 "Configuring system authentication and user settings"
echo ""
print_action "Configuring Touch ID for sudo authentication on compatible hardware..."
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
    print_detail "Skipping key generation to avoid overwriting existing key" 3
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
