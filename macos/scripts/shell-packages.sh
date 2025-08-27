#!/usr/bin/env bash

# Shell packages and plugins installation.

# Install oh-my-zsh.
echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended --keep-zshrc
echo -e "Oh-my-zsh installation successful!\n"

# Install oh-my-zsh plugins.
echo "Installing Oh-my-zsh plugins..."
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/fdw/yazi-zoxide-zsh.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/yazi-zoxide
echo -e "Oh-my-zsh plugins installed successfully!\n"
