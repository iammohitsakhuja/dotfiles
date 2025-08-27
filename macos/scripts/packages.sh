#!/usr/bin/env bash

# Get script directory for reliable script invocations
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Source required utilities
source "${SCRIPT_DIR}/../utils/logging.sh"
source "${SCRIPT_DIR}/../utils/platform.sh"
source "${SCRIPT_DIR}/../utils/mas_installer.sh"
source "${SCRIPT_DIR}/../utils/package_installers.sh"

# Install Homebrew for Apple Silicon
install_homebrew

# Evaluate Homebrew environment to ensure brew command is available
evaluate_homebrew_environment

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install all packages from main Brewfile (this excludes Mac App Store apps)
print_action "Installing Homebrew packages (excluding Mac App Store apps)"
print_detail "You may be prompted for your password by sudo if any packages require elevated permissions"
brew bundle --file "${SCRIPT_DIR}/../Brewfile"
print_success "Homebrew packages installed successfully"

# Handle Mac App Store apps separately with login check
handle_mas_installation "${SCRIPT_DIR}"
mas_return_code=$?

case ${mas_return_code} in
0) print_success "Mac App Store apps installed successfully" ;;
1) print_warning "Mac App Store apps installation failed - continuing with other packages" ;;
2) print_detail "Mac App Store apps installation skipped by user" ;;
*) print_warning "Unexpected exit code from Mac App Store installation: ${mas_return_code}" ;;
esac

# Cleanup the cellar
print_action "Cleaning up Homebrew cache and removing unused packages"
brew cleanup && brew autoremove
print_success "Homebrew cleanup completed"

print_subheader "Language Environments & Packages"
install_go_packages
install_node_packages
install_python_packages
install_ruby_gems

print_subheader "Shell & Editor Plugins"
install_shell_packages
install_vim_packages
