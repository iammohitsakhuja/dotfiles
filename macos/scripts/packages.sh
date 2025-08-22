#!/usr/bin/env bash

# Get script directory for reliable script invocations
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Check if Homebrew can be installed.
if [[ ${OSTYPE} != "darwin"* ]]; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Check if Mac is using Apple Silicon.
if [[ $(uname -m) == 'arm64' ]]; then
    # Install Rosetta 2 for packages required henceforth.
    sudo softwareupdate --install-rosetta --agree-to-license
fi

# Homebrew installation is handled by install.sh - this script assumes brew is available

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install/update Shell and its packages.
echo "Installing/updating Shell and its packages..."
bash "${SCRIPT_DIR}/shell-packages.sh"
echo -e "Done\n\n"

# Install all packages specified in Brewfile.
brew bundle
echo -e "Packages installed successfully\n"

# Set up Perl correctly. Any other changes are in `.zshrc`.
# TODO: Automate this setup without asking for confirmation on autoconfiguration.
PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5" cpan local::lib

# Set up FZF autocompletion and keybindings.
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

# Remove outdated versions from the cellar.
echo "Doing some cleanup..."
brew cleanup && brew autoremove
echo -e "Done\n"

# Install Go and its packages.
echo "Installing Go and its packages..."
bash "${SCRIPT_DIR}/go-packages.sh"
echo -e "Done\n\n"

# Install Node and its packages.
echo "Installing Node and its packages..."
bash "${SCRIPT_DIR}/node-packages.sh"
echo -e "Done\n\n"

# Install Python packages.
echo "Installing Python packages..."
bash "${SCRIPT_DIR}/python-packages.sh"
echo -e "Done\n\n"

# Install Ruby gems.
echo "Installing Ruby gems..."
bash "${SCRIPT_DIR}/ruby-gems.sh"
echo -e "Done\n\n"

# Install Vim packages.
echo "Installing Vim and its packages..."
bash "${SCRIPT_DIR}/vim-packages.sh"
echo -e "Done\n\n"
