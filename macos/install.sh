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

#### TODO: Add backup for Ranger. ####

# Scripts that will run on the start of each session. Remove the ones that you don't need.
STARTUP_SCRIPTS=(
    "greeting.sh"
)

EMAIL="sakhuja.mohit@gmail.com"
NAME="Mohit Sakhuja"

#### TODO: Backup any previously existing files. ####

case $* in
# Copy the files.
--copy | -c)
    echo "Copying config files into $HOME/ ..."
    for file in "${CONFIG_FILES[@]}"; do
        echo "Copying $PWD/config/$file into $HOME/"
        cp $PWD/config/$file $HOME
    done
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    cp $PWD/config/$NVIM_FILE $NVIM_DIR
    echo ""

    echo "Copying startup scripts into $HOME/ ..."
    for file in "${STARTUP_SCRIPTS[@]}"; do
        echo "Copying $PWD/startup_scripts/$file into $HOME/"
        cp $PWD/startup_scripts/$file $HOME
    done
    ;;

# Symlink the files.
*)
    echo "Linking config files into $HOME/ ..."
    for file in "${CONFIG_FILES[@]}"; do
        echo "Symlinking $PWD/config/$file into $HOME/"
        ln -s $PWD/config/$file $HOME
    done
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    ln -s $PWD/config/$NVIM_FILE $NVIM_DIR
    echo ""

    echo "Linking startup scripts into $HOME/ ..."
    for file in "${STARTUP_SCRIPTS[@]}"; do
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

# Make terminal authentication easier by using Touch ID instead of password, if Mac supports it.
# TODO: Add support for Intel Macs with Touch ID.
if [[ `uname -m` == 'arm64' ]]; then
    # Backup the original file.
    sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
    sudo sed -i "3i auth       sufficient     pam_tid.so" /etc/pam.d/sudo
fi

# File to store any API keys in.
touch ~/.api_keys

# Configure git.
git config --global user.email "$EMAIL"
git config --global user.name "$NAME"
git config --global core.editor "nvim"
git config --global core.filemode false
git config --global status.showuntrackedfiles all
git config --global pull.rebase false
git config --global init.defaultBranch main

# Configure `diff-so-fancy` with git.
git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global color.ui true

git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.func       "146 bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"

# Create SSH key pair.
ssh-keygen -t rsa -C "$EMAIL"

# Run installation scripts.
echo -e "\nRunning installation scripts..."

echo "Installing packages..."
bash $PWD/scripts/packages.sh
echo -e "Packages installed successfully!\n"

# Configure Tmux colors.
echo "Configuring Tmux colors..."
tic -x $PWD/config/terminfo/xterm-256color-italic.terminfo
tic -x $PWD/config/terminfo/tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

# Configure MacOS settings.
echo "Configuring MacOS settings..."
bash $PWD/scripts/macos.sh
echo -e "MacOS settings configured successfully!\n"
