#!/usr/bin/env bash

# Setup Imwheel for faster scrolling.
yay -S imwheel

# Link Imwheel settings file.
ln -s $(pwd)/config/.imwheelrc $HOME/.imwheelrc

# Start Imwheel on system startup.
mkdir -p $HOME/.config/systemd/user
ln -s $(pwd)/config/systemd/user/imwheel.service $HOME/.config/systemd/user/imwheel.service
systemctl --user daemon-reload
systemctl --user enable --now imwheel
journalctl --user --unit imwheel

# Might need to add the following to the startup script service file.
# This enables only the buttons 4 & 5 i.e. wheel up and down to be captured by
# Imwheel. Hence, it prevents back/forward buttons from breaking.
# imwheel -b "45"
