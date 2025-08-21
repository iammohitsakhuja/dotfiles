#!/usr/bin/env bash

BREW_PREFIX="$(brew --prefix)"

# Install Bash 4. MacOS' Bash is severely outdated.
# Install this because Bash is needed once in a while.
# Then add `$BREW_PREFIX/bin/bash` to `/etc/shells`.
echo "Installing/updating Bash..."
brew install bash
echo "Done"
if ! grep -F -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
    echo "Adding Bash to /etc/shells... "
    echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    echo -e "Done\n\n"
fi

# Install ZSH - our primary shell.
# Then add `$BREW_PREFIX/bin/zsh` to `/etc/shells`.
echo "Installing/updating Zsh..."
brew install zsh
echo "Done"
if ! grep -F -q "${BREW_PREFIX}/bin/zsh" /etc/shells; then
    echo "Adding Zsh to /etc/shells... "
    echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
    echo -e "Done\nChanging default shell to Zsh... "
    chsh -s ${BREW_PREFIX}/bin/zsh
    echo -e "Done\n\n"
fi

# Install oh-my-zsh.
echo "Installing Oh-my-zsh..."
if ! omz_install_script=$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh); then
    echo "ERROR: Failed to download Oh-my-zsh installer" >&2
    exit 1
fi
sh -c "${omz_install_script}" "" --unattended --keep-zshrc
echo -e "Oh-my-zsh installation successful!\n"

# Install oh-my-zsh plugins.
echo "Installing Oh-my-zsh plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/fdw/yazi-zoxide-zsh.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/yazi-zoxide
echo -e "Oh-my-zsh plugins installed successfully!\n"
