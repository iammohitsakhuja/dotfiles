#!/usr/bin/env bash

# Install Vim Plug for managing plugins in Vim, both for Neovim and Vim.
# Vim.
echo "Installing VimPlug for Vim..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo -e "VimPlug for Vim installed successfully!\n"

# Neovim.
echo "Installing VimPlug for Neovim..."
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo -e "VimPlug for Neovim installed successfully!\n"

# Install Vim plugins.
# Vim.
echo "Installing Vim plugins for Vim..."
vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"
echo -e "Vim plugins for Vim installed successfully!\n"

# Neovim.
echo "Installing Vim plugins for Neovim..."
nvim -es -u ~/.config/nvim/init.vim -i NONE -c "PlugInstall" -c "qa"
echo -e "Vim plugins for Neovim installed successfully!\n"
