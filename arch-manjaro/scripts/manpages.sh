#!/usr/bin/env bash

# Check if Environment is macOS.
if [[ $OSTYPE != "darwin"* && $OSTYPE != "linux-gnu"* ]] ; then
    echo -e "Environment not recognized as macOS or Linux.\nQuitting..."
    exit 1
fi

# Install Git.
if ! [ `which git` ]; then
    brew install git
fi

# Install manpages for C++.
# See https://github.com/jeaye/stdman
# Clone the repository containing the manpages.
REPO="https://github.com/jeaye/stdman"
git clone $REPO stdman

# Go inside the directory.
DIR=$(pwd)
cd stdman

# Install the manpages.
./configure
sudo make install
sudo mandb

# Cleanup.
cd $DIR
rm -rf stdman
