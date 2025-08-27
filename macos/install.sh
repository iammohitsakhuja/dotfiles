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
print_success "macOS environment confirmed and Apple Silicon Mac detected"

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

# Start the sudo keepalive.
sudo_keepalive

print_success "Administrator authentication confirmed"
echo ""

# Install essential dependencies before proceeding
bootstrap_dependencies

print_header "Package Installation & Setup"
echo ""

# Run installation scripts.
print_step 2 5 "Installing packages and applications"
echo ""

print_action "Installing Homebrew packages, applications and plugins..."
bash "${STOW_DIR}/scripts/packages.sh"
BREW_PREFIX=$(brew --prefix)
print_success "Package and application installation complete!"
echo ""

print_header "Backup & File Management"
echo ""

# Backup existing files before stow operations
print_step 3 5 "Backing up existing files and linking dotfiles"
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

# Configure system and user settings.
print_step 4 5 "Configuring system and user settings"
echo ""

print_action "Running system configuration script..."
bash "${STOW_DIR}/scripts/system-configuration.sh" "${email}" "${name}" "${STOW_DIR}" "${BREW_PREFIX}"
print_success "System configuration completed"
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
