#!/usr/bin/env bash

# Install Vim & Neovim via Yay.
echo "Installing Vim, Neovim..."
yay -S vim
yay -S neovim
yay -S python-neovim

# We also need to install 'gvim' as it enables '+clipboard' functionality
# which is missing by default.
yay -S gvim
echo -e "Done\n\n"

echo -e "\nInstalling Vim Plug..."
# Install Vim plug (For Neovim).
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo -e "Done\n\n"

# Install CMake, which is required for building plugins like `YouCompleteMe`.
yay -S cmake

# Build YouCompleteMe.
# Might not be required as it has been added in the .vimrc file as a post hook
# for Vim Plug.
# cd ~/.vim/plugged/YouCompleteMe &&
#     python3 install.py --clang-completer
