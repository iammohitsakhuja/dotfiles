#!/usr/bin/env bash

# Check if Homebrew can be installed.
if [[ $OSTYPE != "darwin"* ]]; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Check if Mac is using Apple Silicon.
if [[ `uname -m` == 'arm64' ]]; then
    # Install Rosetta 2 for packages required henceforth.
    sudo softwareupdate --install-rosetta --agree-to-license
fi

# Install Homebrew if it isn't installed already.
if ! [[ $(which brew) ]]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo -e "Installation successful!\n"

    # Evalulate homebrew correctly.
    # TODO: Make this more elegant. For now, the following commented line has been added to `config/.zprofile`
    # in a conditional manner with support for Intel Macs (which will be dropped at some point in the future).
    # echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    if [ "$(sysctl -in sysctl.proc_translated)" = "0" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Install x86_64 version of homebrew to install packages which don't support Apple Silicon.
# This will be removed in the future once all packages have moved to arm64.
# if [[ `uname -m` == 'arm64' ]]; then
#     arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# fi

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install/update Shell and its packages.
echo "Installing/updating Shell and its packages..."
bash $(pwd)/scripts/shell-packages.sh
echo -e "Done\n\n"

# Install Homebrew bundle.
brew tap homebrew/bundle

# Install all packages specified in Brewfile.
brew bundle
echo -e "Packages installed successfully\n"

# Set up Perl correctly. Any other changes are in `.zshrc`.
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5" cpan local::lib

# Set up FZF autocompletion and keybindings.
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# Remove outdated versions from the cellar.
echo "Doing some cleanup..."
brew cleanup && brew autoremove
echo -e "Done\n"

# Install Go and its packages.
echo "Installing Go and its packages..."
bash $(pwd)/scripts/go-packages.sh
echo -e "Done\n\n"

# Install Node and its packages.
echo "Installing Node and its packages..."
bash $(pwd)/scripts/node-packages.sh
echo -e "Done\n\n"

# Install Python packages.
echo "Installing Python packages..."
bash $(pwd)/scripts/python-packages.sh
echo -e "Done\n\n"

# Install Ruby gems.
echo "Installing Ruby gems..."
bash $(pwd)/scripts/ruby-gems.sh
echo -e "Done\n\n"

# Install Vim packages.
echo "Installing Vim and its packages..."
bash $(pwd)/scripts/vim-packages.sh
echo -e "Done\n\n"
