#!/usr/bin/env bash

# Main orchestration utility containing high-level workflow functions
# This utility coordinates package installation, system setup, and application management

# Source required utilities
ORCHESTRATOR_SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
if [[ ! -d ${ORCHESTRATOR_SCRIPT_DIR} ]] || [[ ${ORCHESTRATOR_SCRIPT_DIR} == "${BASH_SOURCE[0]}" ]]; then
    # Fallback: assume we're being sourced from repo root
    ORCHESTRATOR_SCRIPT_DIR="macos/utils"
fi
source "${ORCHESTRATOR_SCRIPT_DIR}/logging.sh"
source "${ORCHESTRATOR_SCRIPT_DIR}/platform.sh"
source "${ORCHESTRATOR_SCRIPT_DIR}/mas_installer.sh"
source "${ORCHESTRATOR_SCRIPT_DIR}/package_installers.sh"

# Main orchestration function for all package and application installation
# Returns the Homebrew prefix path for use by calling script
install_all_packages() {
    local stow_dir="$1"
    # Install Homebrew for Apple Silicon
    install_homebrew

    # Evaluate Homebrew environment to ensure brew command is available
    evaluate_homebrew_environment

    # Update Homebrew
    print_action "Updating & Upgrading Homebrew..."
    brew update

    # Upgrade any previously installed packages
    brew upgrade
    print_success "Homebrew updated & upgraded successfully"

    # Install all packages from main Brewfile (this excludes Mac App Store apps)
    print_action "Installing Homebrew packages (excluding Mac App Store apps)"
    print_detail "You may be prompted for your password by sudo if any packages require elevated permissions"
    brew bundle --file "${ORCHESTRATOR_SCRIPT_DIR}/../Brewfile"
    print_success "Homebrew packages installed successfully"
    print_newline

    # Handle Mac App Store apps separately with login check
    handle_mas_installation

    # Cleanup the cellar
    print_action "Cleaning up Homebrew cache and removing unused packages"
    brew cleanup && brew autoremove
    print_success "Homebrew cleanup completed"
    print_newline

    print_subheader "Language Environments & Packages"
    install_go_packages
    install_node_packages
    install_python_packages
    install_ruby_gems

    print_subheader "Shell & Editor Plugins"
    install_shell_packages
    install_vim_packages "${stow_dir}"
}
