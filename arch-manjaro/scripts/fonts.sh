#!/usr/bin/env bash

# Get the terminal right.
tic -o $HOME/.terminfo $(pwd)/config/terminfo/xterm-256color-italic.terminfo

# Copy over all the fonts.
sudo cp -r $(pwd)/fonts/. /usr/share/fonts/

# Rebuild the font cache.
fc-cache

# Install any third party fonts.
yay nerd-fonts-complete # For glyphs.
yay noto-fonts-emoji    # For emoji.

# Copy over all the custom font configs.
sudo cp -r $(pwd)/config/fonts/conf.avail/. /etc/fonts/conf.avail/

# Make Noto Fonts Emoji to be the default for displaying emoji.
sudo ln -sf /etc/fonts/conf.avail/75-noto-color-emoji.conf /etc/fonts/conf.d/

# Rebuild the font cache again.
fc-cache
