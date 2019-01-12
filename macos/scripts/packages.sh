#!/usr/bin/env bash

# Check if Homebrew can be installed.
if [[ $OSTYPE != "darwin"* ]]; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install Homebrew if it isn't installed already.
if ! [[ $(which brew) ]]; then
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

echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo -e "Oh-my-zsh installation successful!\n"

# Install oh-my-zsh plugins.
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Install powerlevel9k theme for Zsh.
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# Install Homebrew bundle.
brew tap Homebrew/bundle

# Install all packages specified in Brewfile.
brew bundle
echo -e "Packages installed successfully\n"

# Set up Perl correctly. Any other changes are in `.zshrc`.
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5" cpan local::lib

# Install mas-cli for Mac App Store applications.
brew tap mas-cli/tap
brew tap-pin mas-cli/tap
brew install mas

mas install 1153157709 # Speedtest.
mas install 1160374471 # Pipifier.
mas install 1385985095 # uBlock.
mas install 1284863847 # Unsplash wallpapers.
mas install 409201541  # Pages.

# Remove outdated versions from the cellar.
echo "Doing some cleanup..."
brew cleanup
echo -e "Done\n"

# Update path for Ruby in order to install gems to Ruby provided by Homebrew rather than system Ruby.
export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"

# Install Ruby gems.
echo "Installing Gems..."
gem install lolcat
gem install colorls
gem install mdl
echo -e "Gems installed successfully\n"

# TODO: Do something about adding manpages for gems to the path.
