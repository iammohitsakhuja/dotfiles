#!/usr/bin/env bash

# Ensure proper usage.
if [[ $* == "--help" ]] || [[ $* == "-h" ]]; then
    echo    "Usage: ./install.sh [ -h | --help ] [ -c | --copy ] [ -l | --link ]"
    echo    "       -h, --help  | Show this help"
    echo    "       -l, --link  | Link config files and startup scripts rather than copying (default)"
    echo -e "       -c, --copy  | Copy config files and startup scripts rather than linking\n"
    echo    "To remove the files that you don't need, simply open this installation script and delete their names."
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
    ".mongorc.js"
    ".sqliterc"
    ".tmux.conf"
    ".vimrc"
    ".zshrc"
    "tmux-256color.terminfo"
    "xterm-256color-italic.terminfo"
)

NVIM_DIR="$HOME/.config/nvim"
NVIM_FILE="nvim/init.vim"

# Scripts that will run on the start of each session. Remove the ones that you
# don't need.
STARTUP_SCRIPTS=(
    "greeting.sh"
)

case $* in
    # Copy the files.
    --copy|-c)
        echo "Copying config files into $HOME/ ..."
        for file in ${CONFIG_FILES[@]}
        do
            echo "Copying $PWD/config/$file into $HOME/"
            cp $PWD/config/$file $HOME
        done
        if ! [[ -d $NVIM_DIR ]]; then
            mkdir -p $NVIM_DIR
        fi
        cp $PWD/config/$NVIM_FILE $NVIM_DIR
        echo ""

        echo "Copying startup scripts into $HOME/ ..."
        for file in ${STARTUP_SCRIPTS[@]}
        do
            echo "Copying $PWD/startup_scripts/$file into $HOME/"
            cp $PWD/startup_scripts/$file $HOME
        done
        ;;

    # Symlink the files.
    *)
        echo "Linking config files into $HOME/ ..."
        for file in ${CONFIG_FILES[@]}
        do
            echo "Symlinking $PWD/config/$file into $HOME/"
            ln -s $PWD/config/$file $HOME
        done
        if ! [[ -d $NVIM_DIR ]]; then
            mkdir -p $NVIM_DIR
        fi
        ln -s $PWD/config/$NVIM_FILE $NVIM_DIR
        echo ""

        echo "Linking startup scripts into $HOME/ ..."
        for file in ${STARTUP_SCRIPTS[@]}
        do
            echo "Symlinking $PWD/startup_scripts/$file into $HOME/"
            ln -s $PWD/startup_scripts/$file $HOME
        done
        ;;
esac

# Ask for administrator password.
echo -e "\nInstallation requires administrator authentication..."
sudo -v

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Run installation scripts.
echo -e "\nRunning installation scripts..."

echo "Installing packages..."
bash $PWD/scripts/packages.sh
echo -e "Packages installed successfully!\n"

# Install NVM and Yarn.
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
echo -e "NVM installation successful!\n"

echo "Installing Yarn..."
brew install yarn --without-node
echo -e "Yarn installation successful!\n"

# Install ESLint.
echo "Installing ESLint..."
if [[ `which npm` ]]; then
    npm install -g eslint babel-eslint eslint-config-airbnb
fi
echo -e "ESLint installation successful!\n"

# Install Pip packages.
echo "Installing Pip packages..."
if [[ `which pip3` ]]; then
    pip3 install autopep8 neovim pycodestyle
fi
echo -e "Pip packages installed successfully!\n"

# Install manpages.
echo "Installing Manpages..."
bash $PWD/scripts/manpages.sh
echo -e "Manpages installation successful!\n"

echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo -e "Oh-my-zsh installation successful!\n"

# Configure Tmux colors.
echo "Configuring Tmux colors..."
tic -x $PWD/config/xterm-256color-italic.terminfo
tic -x $PWD/config/tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

