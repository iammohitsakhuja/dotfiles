#!/usr/bin/env bash

RUBY_VERSION=3.2.2

# Make sure `rbenv` is installed.
if ! [[ $(which rbenv) ]]; then
    echo "Installing Rbenv..."
    brew install rbenv
    echo -e "Rbenv installation successful!\n"
fi

# Setup Rbenv.
eval "$(rbenv init -)"

# Install Ruby.
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}
echo -e "Ruby installation successful!\n"

# Install Ruby gems.
if [[ $(which gem) ]]; then
    echo "Installing Gems..."
    gem install colorls
    gem manpages --update-all
    echo -e "Gems installed successfully!\n"
else
    echo -e "Gem command not found! Skipping gems' installation...\n"
fi
