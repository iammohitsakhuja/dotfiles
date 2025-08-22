#!/usr/bin/env bash

# Enable strict error handling
set -e          # Exit on any command failure
set -o pipefail # Fail on any command in a pipeline

source "$(dirname "$0")/utils/logging.sh"

# Validate version format (e.g., "15.0", "14.7.1")
validate_version() {
    local version="$1"
    if [[ ! ${version} =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        die "ERROR: Invalid version format '${version}'. Expected format: X.Y or X.Y.Z (e.g., '15.0' or '14.7.1')"
    fi
}

# Check available disk space for IPSW downloads
check_disk_space() {
    local available=$(df -BG "${CACHE_DIR}" | awk 'NR==2 {gsub(/G/, "", $4); print $4}')
    [[ ${available} -gt 15 ]] || die "ERROR: Insufficient disk space. Need 15GB+, have ${available}GB available"
}

# Function to download macOS IPSW firmware
download_ipsw() {
    local target_version="$1"
    echo "Downloading macOS IPSW firmware version ${target_version}..."

    # Create cache directory if it doesn't exist
    mkdir -p "${CACHE_DIR}"

    # Check available disk space before downloading
    check_disk_space

    if ! mist download firmware "${target_version}" --output-directory "${CACHE_DIR}"; then
        die "ERROR: Failed to download macOS IPSW version ${target_version}. Check if version is available."
    fi
    echo "IPSW download completed successfully."
}

# Initialize option variables.
version=""
CACHE_DIR="${HOME}/.cache/dotfiles"

show_help() {
    echo "Usage: ./setup-development.sh [-h | --help] [-v | --version]"
    echo "       -h, --help     | Show this help."
    echo '       -v, --version  | Specify macOS version (e.g. "15.0" for Sequoia). Uses latest if not specified.'
    echo ""
    echo "Examples:"
    echo "  ./setup-development.sh                # Use latest macOS IPSW"
    echo "  ./setup-development.sh --version 15.0 # Use specific version"
    echo ""
    echo "This script will:"
    echo "1. Install UTM and mist-cli (if not present)"
    echo "2. Download the specified macOS IPSW firmware"
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
        if [[ -n $2 ]]; then
            validate_version "$2"
            version=$2
            shift 2
        else
            die 'ERROR: "--version" requires a non-empty option argument.'
        fi
        ;;
    --version=?*)
        version=${1#*=} # Delete everything up to "=" and assign the remainder.
        validate_version "${version}"
        shift
        ;;
    --version=) # Handle the case of an empty --version=.
        die 'ERROR: "--version" requires a non-empty option argument.'
        ;;
    *) # Default case: No more options, so break out of the loop.
        break
        ;;
    esac
done

echo "Setting up UTM for dotfiles testing..."

# Install UTM if not present
if ! command -v utmctl &>/dev/null; then
    echo "Installing UTM..."
    brew install --cask utm
fi

# Install mist-cli if not present
if ! command -v mist &>/dev/null; then
    echo "Installing mist-cli..."
    brew install mist-cli
fi

# Determine target macOS version
if [[ -n ${version} ]]; then
    TARGET_VERSION="${version}"
    echo "Target macOS version: ${TARGET_VERSION}"
else
    echo "Getting latest available macOS version..."
    TARGET_VERSION=$(mist list firmware | grep -E "macOS.*[0-9]+\.[0-9]+" | head -1 | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?" | head -1)
    if [[ -z ${TARGET_VERSION} ]]; then
        die "ERROR: Could not determine latest macOS version. Try specifying a version with --version."
    fi
    echo "Latest available version: ${TARGET_VERSION}"
fi

# Check if any IPSW already exists first
EXISTING_IPSW=$(find "${CACHE_DIR}" -name '*.ipsw' -type f 2>/dev/null | head -1)
if [[ -n ${EXISTING_IPSW} ]]; then
    echo "Found existing macOS IPSW at: ${EXISTING_IPSW}"

    # Check if existing IPSW filename contains the target version
    if [[ ${EXISTING_IPSW} == *"${TARGET_VERSION}"* ]]; then
        echo "Existing IPSW appears to match requested version (${TARGET_VERSION}). Using existing IPSW."
    else
        echo "Existing IPSW may not match requested version (${TARGET_VERSION}). Downloading specific version..."
        download_ipsw "${TARGET_VERSION}"
    fi
else
    echo "No existing IPSW found."
    download_ipsw "${TARGET_VERSION}"
fi

# Find the IPSW (should exist now)
IPSW_PATH=$(find "${CACHE_DIR}" -name '*.ipsw' -type f 2>/dev/null | head -1)
if [[ ! -f ${IPSW_PATH} ]]; then
    echo "Error: macOS IPSW not found after download attempt"
    echo "Available IPSW files:"
    ls -la "${CACHE_DIR}"/*.ipsw 2>/dev/null || echo "No IPSW files found in ${CACHE_DIR}"
    exit 1
fi

echo "macOS IPSW ready at: ${IPSW_PATH}"

echo ""
echo "==============================================="
echo "✅ macOS IPSW Ready for UTM Setup"
echo "==============================================="
echo ""
echo "Next steps:"
echo "1. Open UTM and create a new macOS VM"
echo "2. Name the VM 'dotfiles-test' for CLI management"
echo "3. Use the IPSW file at: ${IPSW_PATH}"
echo "4. Configure shared directory to: $(pwd)"
echo "5. Complete VM setup following docs/development-environment.md"
echo ""
echo "For detailed setup instructions, see: docs/development-environment.md"
