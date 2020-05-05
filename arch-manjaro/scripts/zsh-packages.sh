#!/usr/bin/env bash

# Install/update ZSH.
echo "Installing/updating ZSH..."
yay -S zsh
echo -e "Done\n"

# Change default shell to ZSH.
echo "Changing default shell to Zsh..."
chsh -s /bin/zsh
echo -e "Done\n"

# Install oh-my-zsh.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# Install oh-my-zsh plugins.
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Install powerlevel9k theme for Zsh.
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
