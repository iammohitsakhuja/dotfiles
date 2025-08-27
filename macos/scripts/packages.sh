#!/usr/bin/env bash

# Get script directory for reliable script invocations
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Source required utilities
source "${SCRIPT_DIR}/../utils/logging.sh"
source "${SCRIPT_DIR}/../utils/platform.sh"

# Install Homebrew for Apple Silicon
install_homebrew

# Evaluate Homebrew environment to ensure brew command is available
evaluate_homebrew_environment

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install/update Shell and its packages.
echo "Installing/updating Shell and its packages..."
bash "${SCRIPT_DIR}/shell-packages.sh"
echo -e "Done\n\n"

# Install all packages from main Brewfile (this excludes Mac App Store apps).
echo "Installing Homebrew packages (excluding Mac App Store apps)..."
brew bundle --file "${SCRIPT_DIR}/../Brewfile"
echo "Homebrew packages (excluding Mac App Store apps) installed successfully"

# Handle Mac App Store apps separately with login check
echo "Installing Mac App Store apps..."
bash "${SCRIPT_DIR}/install-mas-apps.sh"
mas_exit_code=$?

case ${mas_exit_code} in
0) echo "Mac App Store apps installed successfully" ;;
1) echo "WARNING: Mac App Store apps installation failed - continuing with other packages" ;;
2) echo "Mac App Store apps installation skipped by user" ;;
*) echo "WARNING: Unexpected exit code from Mac App Store installation: ${mas_exit_code}" ;;
esac
echo ""

# Set up Perl correctly. Any other changes are in `.zshrc`.
PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5" PERL_MM_USE_DEFAULT=1 cpan local::lib

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
