#!/usr/bin/env bash

NVM_VERSION="0.35.2"

# Install NVM and Node.
echo "Installing NVM and Node..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash

# Run this to load NVM right now as we are going to use it in the next step to
# install Node.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

nvm install --lts
echo -e "NVM and Node installation successful!\n"

# Install Yarn.
echo "Installing Yarn..."
yay -S yarn
echo -e "Yarn installation successful!\n"

# Install NPM packages.
echo "Installing NPM packages..."
if [[ $(which npm) ]]; then
    npm install -g express-generator
    npm install -g fixjson
    npm install -g prettier
    npm install -g taskbook
fi
echo -e "NPM packages installed successfully!\n"
