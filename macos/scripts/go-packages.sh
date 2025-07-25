#!/usr/bin/env bash

GO_VERSION=1.24.4

# Make sure `goenv` is installed.
if ! [[ $(which goenv) ]]; then
    echo "Installing Goenv..."
    brew install goenv
    echo -e "Goenv installation successful!\n"
fi

# Setup Goenv.
eval "$(goenv init -)"

# Install Go.
goenv install ${GO_VERSION}
goenv global ${GO_VERSION}
echo -e "Go installation successful!\n"

# Install Go packages.
if [[ $(which go) ]]; then
    echo "Installing Go packages..."
    # Uncomment the following line, and add package names to install global go packages.
    # go install
    echo -e "Go packages installed successfully!\n"
fi
