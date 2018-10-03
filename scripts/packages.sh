#!/usr/bin/env bash

# This file is a slightly modified version of Mathias' Homebrew script.
# https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh

# Check if Homebrew can be installed.
if [[ $OSTYPE != "darwin"* ]]; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install Homebrew if it isn't installed already.
if ! [[ `which brew` ]]; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo -e "Installation successful!\n"
fi

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install Bash 4. MacOS' Bash is severely outdated.
# Install this because Bash is needed once in a while.
# Then add `/usr/local/bin/bash` to `/etc/shells`.
brew install bash
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
    echo "Adding Bash to /etc/shells... "
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    echo "Done"
fi

# Install ZSH - our primary shell.
# Then add `/usr/local/bin/zsh` to `/etc/shells`.
brew install zsh
if ! fgrep -q '/usr/local/bin/zsh' /etc/shells; then
    echo "Adding Zsh to /etc/shells... "
    echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells
    echo -e "Done\nChanging default shell to Zsh... "
    chsh -s /usr/local/bin/zsh
    echo "Done"
fi

# Install Homebrew bundle.
brew tap Homebrew/bundle

# Install all packages.
brew bundle
echo -e "Packages installed successfully\n"

# Remove outdated versions from the cellar.
echo "Doing some cleanup..."
brew cleanup

