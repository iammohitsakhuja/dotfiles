#!/usr/bin/env bash

# This file is a slightly modified version of Mathias' Homebrew script.
# https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh

# Check if Homebrew can be installed.
if [[ $OSTYPE != "darwin"* ]] ; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install Homebrew if it isn't installed already.
if ! [ `which brew` ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew.
brew update

# Upgrade any previously installed packages.
brew upgrade

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install Bash 4. MacOS' Bash is severely outdated.
# Install this because Bash is needed once in a while.
# Then add `/usr/local/bin/bash` to `/etc/shells`.
brew install bash
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
fi;

# Install ZSH - our primary shell.
# Then add `/usr/local/bin/zsh` to `/etc/shells`.
brew install zsh
if ! fgrep -q '/usr/local/bin/zsh' /etc/shells; then
    echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells;
    chsh -s /usr/local/bin/zsh;
fi;

# Install plugins for ZSH.
brew install zsh-completions
brew install zsh-syntax-highlighting

# Install `wget`.
brew install wget

# Install `tmux`.
brew install tmux

# Install `yarn` for managing packages.
brew install yarn

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install grep --with-default-names
brew install screen

# Install programming related packages.
brew install clang-format
brew install cmake
brew install lua
brew install mongodb
brew install python
brew install perl
brew install sqlite

# Install other useful binaries.
brew install ack
brew install git
brew install tree

# Remove outdated versions from the cellar.
brew cleanup

