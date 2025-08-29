#!/usr/bin/env bash

# Bootstrap utilities for dotfiles installation
# This file contains functions to install essential dependencies needed for the installation process

# Source shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"

# Function to install essential dependencies needed for the installation
bootstrap_dependencies() {
    print_step 1 5 "Checking and installing essential dependencies"
    echo ""

    # Install Rosetta 2 (required for Apple Silicon compatibility)
    install_rosetta2

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

    echo ""
    print_success "Essential dependencies are ready!"
    echo ""
}
