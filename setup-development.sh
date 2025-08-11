#!/usr/bin/env bash

set -e

# Helper function to exit the script.
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Function to download macOS installer
download_installer() {
    local target_version="$1"
    echo "Downloading macOS installer version $target_version..."
    if ! sudo softwareupdate --download --fetch-full-installer --full-installer-version "$target_version"; then
        die "ERROR: Failed to download macOS installer version $target_version. Check if version is available."
    fi
    echo "Download completed successfully."
}

# Initialize option variables.
version=""

show_help() {
    echo "Usage: ./setup-development.sh [-h | --help] [-v | --version]"
    echo "       -h, --help     | Show this help."
    echo "       -v, --version  | Specify macOS installer version (e.g. \"15.6\"). Uses latest if not specified."
    echo ""
    echo "Examples:"
    echo "  ./setup-development.sh                # Use latest macOS installer"
    echo "  ./setup-development.sh --version 15.6 # Use specific version"
    echo ""
    echo "This script will:"
    echo "1. Install UTM (if not present)"
    echo "2. Download the specified macOS installer"
    echo "3. Provide setup instructions for creating a VM"
}

# Parse command line arguments
while :; do
    case $1 in
    -h | -\? | --help)
        show_help
        exit
        ;;
    -v | --version)
        if [[ "$2" ]]; then
            version=$2
            shift 2
        else
            die "ERROR: \"--version\" requires a non-empty option argument."
        fi
        ;;
    --version=?*)
        version=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --version=) # Handle the case of an empty --version=.
        die "ERROR: \"--version\" requires a non-empty option argument."
        ;;
    *) # Default case: No more options, so break out of the loop.
        break
        ;;
    esac
done

echo "Setting up UTM for dotfiles testing..."

# Install UTM if not present
if ! command -v utmctl &> /dev/null; then
    echo "Installing UTM..."
    brew install --cask utm
fi

# Determine target macOS version
if [[ -n "$version" ]]; then
    TARGET_VERSION="$version"
    echo "Target macOS version: $TARGET_VERSION"
else
    echo "Getting latest available macOS version..."
    TARGET_VERSION=$(softwareupdate --list-full-installers 2>/dev/null | grep "macOS" | head -1 | awk '{print $6}' | sed 's/,$//')
    if [[ -z "$TARGET_VERSION" ]]; then
        die "ERROR: Could not determine latest macOS version. Try specifying a version with --version."
    fi
    echo "Latest available version: $TARGET_VERSION"
fi

# Check if any installer already exists first
EXISTING_INSTALLER=$(ls -d /Applications/Install\ macOS*.app 2>/dev/null | head -1)
if [[ -n "$EXISTING_INSTALLER" ]]; then
    echo "Found existing macOS installer at: $EXISTING_INSTALLER"

    # Extract version from installer using system_profiler or defaults
    EXISTING_VERSION=$(defaults read "$EXISTING_INSTALLER/Contents/Info.plist" DTPlatformVersion 2>/dev/null || echo "unknown")
    echo "Existing installer version: $EXISTING_VERSION"

    # If we have a specific version requirement, check if it matches
    if [[ "$EXISTING_VERSION" == "$TARGET_VERSION" ]]; then
        echo "Existing installer version matches requested version. Using existing installer: $EXISTING_INSTALLER"
    else
        echo "Existing installer version ($EXISTING_VERSION) doesn't match requested version ($TARGET_VERSION)"
        download_installer "$TARGET_VERSION"
    fi
else
    echo "No existing installer found."
    download_installer "$TARGET_VERSION"
fi

# Find the installer (should exist now)
INSTALLER_PATH=$(ls -d /Applications/Install\ macOS*.app 2>/dev/null | head -1)
if [ ! -d "$INSTALLER_PATH" ]; then
    echo "Error: macOS installer not found after download attempt"
    echo "Available installers:"
    ls -la /Applications/ | grep -i "install.*macos" || echo "No macOS installers found"
    exit 1
fi

echo "macOS installer ready at: $INSTALLER_PATH"

# Create VM configuration (this is more complex with utmctl)
echo "Creating UTM VM 'dotfiles-test'..."
if ! utmctl create --name "dotfiles-test" \
    --os macos \
    --installer "$INSTALLER_PATH" \
    --memory 8096 \
    --disk-size 50 \
    --shared-directory "$(pwd)"; then
    die "ERROR: Failed to create UTM VM. Check UTM installation and try again."
fi

echo "VM created successfully!"
echo "Starting VM for initial setup..."
if ! utmctl start "dotfiles-test"; then
    echo "WARNING: Failed to start VM automatically. You can start it manually via UTM interface."
fi

echo ""
echo "==============================================="
echo "✅ UTM Development Environment Setup Complete"
echo "==============================================="
echo ""
echo "Next steps:"
echo "1. Complete macOS installation in the VM"
echo "2. Your dotfiles will be available at: /Volumes/My Shared Files/"
echo "3. Test installation: cd /Volumes/My\\ Shared\\ Files && ./macos/install.sh --email you@example.com --name 'Your Name'"
echo ""
echo "VM Management:"
echo "• Use ./test/utils/vm-manager.sh for VM operations"
echo "• Use ./test/scripts/test-runner.sh for testing workflows"
echo ""
echo "For help with testing: ./test/scripts/test-runner.sh --help"
