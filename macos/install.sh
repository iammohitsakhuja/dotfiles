#!/usr/bin/env bash

# Ensure proper usage.
if [[ $* == "--help" ]] || [[ $* == "-h" ]]; then
    echo "Usage: ./install.sh [ -h | --help ] [ -c | --copy ] [ -l | --link ]"
    echo "       -h, --help  | Show this help"
    echo "       -l, --link  | Link config files and startup scripts rather than copying (default)"
    echo -e "       -c, --copy  | Copy config files and startup scripts rather than linking\n"
    echo "To remove the files that you don't need, simply open this installation script and delete their names."
    exit 0
fi

# Get the current working directory.
PWD=$(pwd)

# Config files. Remove the files that you don't need.
CONFIG_FILES=(
    ".aliases"
    ".clang-format"
    ".eslintrc.json"
    ".exports"
    ".hyper.js"
    ".ideavimrc"
    ".mongorc.js"
    ".sqliterc"
    ".tmux.conf"
    ".vimrc"
    ".zshrc"
)

# Path to Neovim config file.
NVIM_DIR="$HOME/.config/nvim"
NVIM_FILE="nvim/init.vim"

# Scripts that will run on the start of each session. Remove the ones that you don't need.
STARTUP_SCRIPTS=(
    "greeting.sh"
)

case $* in
# Copy the files.
--copy | -c)
    echo "Copying config files into $HOME/ ..."
    for file in ${CONFIG_FILES[@]}; do
        echo "Copying $PWD/config/$file into $HOME/"
        cp $PWD/config/$file $HOME
    done
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    cp $PWD/config/$NVIM_FILE $NVIM_DIR
    echo ""

    echo "Copying startup scripts into $HOME/ ..."
    for file in ${STARTUP_SCRIPTS[@]}; do
        echo "Copying $PWD/startup_scripts/$file into $HOME/"
        cp $PWD/startup_scripts/$file $HOME
    done
    ;;

# Symlink the files.
*)
    echo "Linking config files into $HOME/ ..."
    for file in ${CONFIG_FILES[@]}; do
        echo "Symlinking $PWD/config/$file into $HOME/"
        ln -s $PWD/config/$file $HOME
    done
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    ln -s $PWD/config/$NVIM_FILE $NVIM_DIR
    echo ""

    echo "Linking startup scripts into $HOME/ ..."
    for file in ${STARTUP_SCRIPTS[@]}; do
        echo "Symlinking $PWD/startup_scripts/$file into $HOME/"
        ln -s $PWD/startup_scripts/$file $HOME
    done
    ;;
esac

# Ask for administrator password.
echo -e "\nInstallation requires administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# File to store any API keys in.
touch ~/.api_keys

# Configure git.
git config --global user.email "sakhuja.mohit@gmail.com"
git config --global user.name "Mohit Sakhuja"
git config --global core.editor "nvim"
git config --global core.filemode false

# Create SSH key pair.
ssh-keygen -t rsa -C "sakhuja.mohit@gmail.com"

# Run installation scripts.
echo -e "\nRunning installation scripts..."

echo "Installing packages..."
bash $PWD/scripts/packages.sh
echo -e "Packages installed successfully!\n"

# Install NVM.
echo "Installing NVM and Node..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# Do this to be able to use NVM now.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Install node.
nvm install --lts
echo -e "NVM and Node installation successful!\n"

# Install yarn.
echo "Installing Yarn..."
brew install yarn --without-node
echo -e "Yarn installation successful!\n"

# Install ESLint.
echo "Installing NPM packages..."
if [[ $(which npm) ]]; then
    npm install -g eslint babel-eslint eslint-config-airbnb
    npm install -g express-generator
    npm install -g fixjson
    npm install -g prettier
    npm install -g stylelint stylelint-scss stylelint-config-standard stylelint-config-recommended-scss
    npm install -g taskbook
fi
echo -e "NPM packages installed successfully!\n"

# Install Pip packages.
echo "Installing Pip packages..."
if [[ $(which pip3) ]]; then
    pip3 install black
    pip3 install gitlint
    pip3 install neovim
    pip3 install virtualenv
fi
echo -e "Pip packages installed successfully!\n"

# Install manpages.
# echo "Installing Manpages..."
# bash $PWD/scripts/manpages.sh
# echo -e "Manpages installation successful!\n"

# Install Vim Plug for managing plugins in Vim, both for Neovim and Vim.
# Vim.
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Neovim.
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo -e "Vim-Plug has been installed. You can install Vim plugins from within (Neo) Vim now.\n"

# Configure Tmux colors.
echo "Configuring Tmux colors..."
tic -x $PWD/config/xterm-256color-italic.terminfo
tic -x $PWD/config/tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

# Configure MacOS settings.
echo "Configuring MacOS settings..."
bash $PWD/scripts/macos.sh
echo -e "MacOS settings configured successfully!\n"
