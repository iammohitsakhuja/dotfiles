#!/usr/bin/env bash

# Update path for Ruby in order to install gems to Ruby provided by Homebrew rather than system Ruby.
export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.0.0/bin:$PATH"

# Install Ruby gems.
echo "Installing Gems..."
gem install lolcat
gem install colorls
gem install mdl
echo -e "Gems installed successfully\n"

# TODO: Do something about adding manpages for gems to the path.
