#!/usr/bin/env bash

set -e

# Helper function to exit the script.
die() {
    printf '%s\n' "$1" >&2
    exit 1
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

# Download macOS installer
if [[ -n "$version" ]]; then
    echo "Downloading macOS installer version $version..."
    sudo softwareupdate --download --fetch-full-installer --full-installer-version "$version"
else
    echo "Downloading latest available macOS installer..."
    # Get the latest version available
    LATEST_VERSION=$(softwareupdate --list-full-installers | grep "macOS" | head -1 | awk '{print $6}' | sed 's/,$//')
    echo "Latest available version: $LATEST_VERSION"
    sudo softwareupdate --download --fetch-full-installer --full-installer-version "$LATEST_VERSION"
fi

# Find the installer
INSTALLER_PATH=$(ls -d /Applications/Install\ macOS*.app 2>/dev/null | head -1)
if [ ! -d "$INSTALLER_PATH" ]; then
    echo "Error: macOS installer not found"
    echo "Available installers:"
    ls -la /Applications/ | grep -i "install.*macos" || echo "No macOS installers found"
    exit 1
fi

echo "macOS installer ready at: $INSTALLER_PATH"

# After the installer download, add:
echo "Creating UTM VM..."

# Create VM configuration (this is more complex with utmctl)
utmctl create --name "dotfiles-test" \
    --os macos \
    --installer "$INSTALLER_PATH" \
    --memory 8096 \
    --disk-size 50 \
    --shared-directory "$(pwd)"

echo "VM created! Starting installation..."
utmctl start "dotfiles-test"

echo ""
echo "Next steps:"
echo "After VM setup, your dotfiles will be at: /Volumes/My Shared Files/"
