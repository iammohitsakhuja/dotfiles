#!/usr/bin/env bash

# Check if Environment is macOS.
if [[ $OSTYPE != "darwin"* ]] ; then
    echo -e "Environment not recognized as macOS.\nQuitting..."
    exit 1
fi

# Install manpages for C++.
# See https://github.com/jeaye/stdman
if ! [ `which git` ]; then
    bash brew.sh
fi

# Clone the repository containing the manpages.
REPO="https://github.com/jeaye/stdman"
git clone $REPO stdman

# Go inside the directory.
DIR=$(pwd)
cd stdman

# Install the manpages.
./configure
make install

# Cleanup.
cd $DIR
rm -rf stdman

