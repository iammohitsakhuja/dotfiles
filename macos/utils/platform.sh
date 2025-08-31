#!/usr/bin/env bash

# Platform-specific utilities for dotfiles scripts
# This file provides platform detection, dependency management, and system-specific operations.

# Source shared utilities for logging functions
PLATFORM_SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
if [[ ! -d ${PLATFORM_SCRIPT_DIR} ]] || [[ ${PLATFORM_SCRIPT_DIR} == "${BASH_SOURCE[0]}" ]]; then
    # Fallback: assume we're being sourced from repo root
    PLATFORM_SCRIPT_DIR="macos/utils"
fi
source "${PLATFORM_SCRIPT_DIR}/logging.sh"

# Helper function to exit the script with an error message
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Check if running on Apple Silicon Mac
is_apple_silicon() {
    # Check the OS is macOS and the architecture is arm64
    [[ ${OSTYPE} == 'darwin'* && $(uname -m) == 'arm64' ]]
}

# Require Apple Silicon Mac and fail if not
require_apple_silicon() {
    if ! is_apple_silicon; then
        die "ERROR: These dotfiles only support Apple Silicon Macs. Other Operating Systems and Intel Macs are not supported."
    fi
}

# Check if terminal has Full Disk Access
has_full_disk_access() {
    # Try to read a system file that requires Full Disk Access
    plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null 2>&1
}

# Require Full Disk Access and guide user to enable it if not available
require_full_disk_access() {
    if ! has_full_disk_access; then
        # Open System Settings to the relevant panel
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_All"

        die "ERROR: This script requires your terminal app to have Full Disk Access. Add this terminal to the Full Disk Access list in System Settings > Privacy & Security, quit the app, and re-run this script."
    fi
}

# Evaluate Homebrew environment for Apple Silicon
evaluate_homebrew_environment() {
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Install a package via Homebrew if it's not already available
install_package_if_missing() {
    local package="$1"
    local command_name="${2:-$1}"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        print_action "Installing ${package}..."
        brew install "${package}"
        print_success "${package} installation completed"
    else
        print_success "${package} already installed"
    fi
}

# Install Rosetta 2 (required for Apple Silicon compatibility)
install_rosetta2() {
    print_action "Installing Rosetta 2..."
    if sudo softwareupdate --install-rosetta --agree-to-license 2>/dev/null; then
        print_success "Rosetta 2 installation completed"
    else
        print_success "Rosetta 2 already installed or installation skipped"
    fi
}

# Install Homebrew for Apple Silicon
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        print_action "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Evaluate homebrew environment for the current session
        evaluate_homebrew_environment
        print_success "Homebrew installation completed"
    else
        print_success "Homebrew already installed"
    fi
    print_newline
}
