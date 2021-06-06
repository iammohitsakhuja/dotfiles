#!/usr/bin/env bash

# Install Bash 4. MacOS' Bash is severely outdated.
# Install this because Bash is needed once in a while.
# Then add `/usr/local/bin/bash` to `/etc/shells`.
echo "Installing/updating Bash..."
brew install bash
echo "Done"
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
    echo "Adding Bash to /etc/shells... "
    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
    echo -e "Done\n\n"
fi

# Install ZSH - our primary shell.
# Then add `/usr/local/bin/zsh` to `/etc/shells`.
echo "Installing/updating Zsh..."
brew install zsh
echo "Done"
if ! fgrep -q '/usr/local/bin/zsh' /etc/shells; then
    echo "Adding Zsh to /etc/shells... "
    echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells
    echo -e "Done\nChanging default shell to Zsh... "
    chsh -s /usr/local/bin/zsh
    echo -e "Done\n\n"
fi

# Install oh-my-zsh.
echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
echo -e "Oh-my-zsh installation successful!\n"

# Install oh-my-zsh plugins.
echo "Installing Oh-my-zsh plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
echo -e "Oh-my-zsh plugins installed successfully!\n"

# Install Powerlevel9k theme for Zsh.
echo "Installing Powerlevel9k theme for Zsh..."
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
echo -e "Powerlevel9k theme installed successfully!\n"
