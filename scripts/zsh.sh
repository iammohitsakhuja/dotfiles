#!/usr/bin/env bash

# Check if Environment is macOS.
if [[ $OSTYPE != "darwin"* ]] ; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install Homebrew if it isn't already installed.
if ! [ `which brew` ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install ZSH if it isn't already installed.
# Make it the default shell.
brew install zsh
if ! fgrep -q '/usr/local/bin/zsh' /etc/shells; then
    echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells;
    chsh -s /usr/local/bin/zsh;
fi;

# Install plugins for ZSH.
brew install zsh-completions
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions

# Install oh-my-zsh.
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

