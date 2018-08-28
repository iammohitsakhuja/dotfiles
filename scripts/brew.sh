#!/usr/bin/env bash

# This file is a slightly modified version of Mathias' Homebrew script.
# https://github.com/mathiasbynens/dotfiles/blob/master/brew.sh

# Check if Homebrew/Linuxbrew can be installed.
if [[ $OSTYPE != "darwin"* && $OSTYPE != "linux-gnu" ]]; then
    echo -e "Environment not recognized as macOS/Linux.\nQuitting..."
    exit 1
fi

# Install Homebrew/Linuxbrew if it isn't installed already.
if ! [ `which brew` ]; then
    if [[ $OSTYPE == "darwin"* ]]; then
        echo "Installing Homebrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Installing Linuxbrew"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
        test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
        test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
        test -r ~/.bash_profile && echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.bash_profile
        echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.profile
    fi
    echo "Installation successful!"
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

# Install plugins for ZSH.
echo "Installing plugins for Zsh... "
brew install zsh-completions
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions
echo "Done"

# Install `wget`.
brew install wget

# Install `tmux`.
brew install tmux

# Install `yarn` for managing packages. Use 'nvm' for installing Node.
brew install yarn --without-node

# Install pandoc for converting Markdown to PDF.
brew install pandoc

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install grep --with-default-names
brew install screen

# Install programming related packages.
brew install clang-format
brew install cmake
brew install lua
brew install mongodb
brew install perl
brew install python
brew install sqlite

# Install other useful binaries.
brew install ack
brew install git
brew install tree

# Install some fun packages.
brew install lolcat

echo -e "Packages installed successfully\n"

# Remove outdated versions from the cellar.
echo "Doing some cleanup..."
brew cleanup

