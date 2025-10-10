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
source "${ORCHESTRATOR_SCRIPT_DIR}/plugin_installers.sh"

# Main orchestration function for all software installation
# This function handles Homebrew, Mac App Store apps, and language environments
install_all_packages() {
    local stow_dir="$1"

    print_subheader "Core Software Installation"
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
    print_newline

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

    print_subheader "Language Environment Installation"
    install_go_packages
    install_node_packages
    install_python_packages
    install_ruby_gems
    install_rust_packages
    install_java_tools
    print_success "Language Environment installation complete"
}

# Main orchestration function for all plugin installation
# This function is called post-stow to ensure all config files are available
install_all_plugins() {
    print_subheader "Plugin Installation"

    install_shell_plugins
    install_vim_plugins
    install_tmux_plugins
    install_yazi_plugins
    install_bat_themes

    print_success "Plugin installation complete"
}
