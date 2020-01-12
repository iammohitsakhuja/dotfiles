#!/usr/bin/env bash

# Check if Yay is installed. If not, then install it.
if ! [[ $(which yay); ]]; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
fi

# Set yay config.
yay --save --answerclean All --answerdiff None

# Update everything on the machine.
echo "Updating everything on the machine..."
yay
echo -e "Update finished.\n"

# Install/update ZSH and its packages.
echo "Installing/updating ZSH and its packages..."
bash $(pwd)/scripts/zsh-packages.sh
echo -e "Done\n\n"

# Install system packages.
echo -e "Installing system packages...\n"
bash $(pwd)/scripts/system-packages.sh
echo -e "Done\n\n"

# Install Vim & Neovim via Yay.
echo "Installing Vim and its packages..."
bash $(pwd)/scripts/vim-packages.sh
echo -e "Done\n\n"

# Install Node and its packages.
echo "Installing Node and its packages..."
bash $(pwd)/scripts/node-packages.sh
echo -e "Done\n\n"

# Install Python and its packages.
echo "Installing Python and its packages..."
bash $(pwd)/scripts/python-packages.sh
echo -e "Done\n\n"

# Install Ruby gems.
echo "Installing Ruby gems..."
bash $(pwd)/scripts/ruby-gems.sh
echo -e "Done\n\n"

echo "Installing packages via Yay..."

# Install utilities.
yay -S tmux
yay -S highlight
yay -S ranger

# Faster and easier finding.
yay -S fd # Faster alternative to `find` command.
yay -S the_silver_searcher # Provides the `ag` command.

# Programming related packages.
# yay -S clang-format ### TODO: Find the correct package for this.
yay -S google-java-format
# yay -S mongodb ### TODO: Make sure this works.
yay -S lua
yay -S jdk8-openjdk # Required for any packages that depend on JDK.
yay -S postgresql
yay -S ruby # This will also install the `gem` command.
yay -S shfmt

# Install other useful binaries.
yay -S ack
yay -S tree

# Install GUI applications.
yay -S mailspring
yay -S dropbox
yay -S firefox-developer-edition
yay -S chromium
yay -S solaar
yay -S opera
yay -S slack-desktop
yay -S spotify
yay -S webtorrent-desktop

# Install development utilities.
yay -S zeal
yay -S docker
yay -S gitkraken
yay -S hyper
yay -S postman
yay -S intellij-idea-ultimate-edition
yay -S webstorm
yay -S love
yay -S visual-studio-code-bin

echo -e "Packages installed successfully via Yay\n"
