#!/usr/bin/env bash

BREW_PREFIX="$(brew --prefix)"

# Update path for Ruby in order to install gems to Ruby provided by Homebrew rather than system Ruby.
export PATH="$BREW_PREFIX/opt/ruby/bin:$BREW_PREFIX/lib/ruby/gems/3.0.0/bin:$PATH"

# Install Ruby gems.
echo "Installing Gems..."
gem install colorls lolcat mdl
echo -e "Gems installed successfully\n"

# TODO: Do something about adding manpages for gems to the path.
