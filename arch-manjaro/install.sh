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
    ".taskbook.json"
    ".tmux.conf"
    ".vimrc"
    ".zshrc"
)

# Path to Neovim config file.
NVIM_DIR="$HOME/.config/nvim"
NVIM_FILE="nvim/init.vim"

# Path to Ranger config file.
RANGER_DIR="$HOME/.config/ranger"
RANGER_FILE="ranger/scope.sh"

# Scripts that will run on the start of each session. Remove the ones that you
# don't need.
STARTUP_SCRIPTS=(
    "greeting.sh"
)

#### TODO: Backup any previously existing files. ####

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
    if ! [[ -d $RANGER_DIR ]]; then
        mkdir -p $RANGER_DIR
    fi
    cp $PWD/config/$RANGER_FILE $RANGER_DIR
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
    if ! [[ -d $RANGER_DIR ]]; then
        mkdir -p $RANGER_DIR
    fi
    ln -s $PWD/config/$RANGER_FILE $RANGER_DIR
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

# Keep `sudo` alive i.e. update existing time stamp until `./install.sh` has
# finished.
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

# Install manpages.
# echo "Installing Manpages..."
# bash $PWD/scripts/manpages.sh
# echo -e "Manpages installation successful!\n"
#
# # Configure Tmux colors.
# echo "Configuring Tmux colors..."
# tic -x $PWD/config/xterm-256color-italic.terminfo
# tic -x $PWD/config/tmux-256color.terminfo
# echo -e "Tmux colors configured successfully!\n"
