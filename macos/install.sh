#!/usr/bin/env bash

# Helper function to exit the script.
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialise the option variables.
# This ensures we are not contaminated by variables from the environment.
symlink=1 # 0 is for copy, 1 is for symlink.
email=
name=

# TODO: Add a verbose option.
show_help() {
    echo "Usage: ./install.sh [-h | --help] [-c | -l | --copy | --link] [-e | --email] [-n | --name]"
    echo "       -h, --help     | Show this help."
    echo "       -l, --link     | Link config files and startup scripts rather than copying (default)."
    echo "       -c, --copy     | Copy config files and startup scripts rather than linking."
    echo "       -e, --email    | The email that you would like to use for setting up things like git, ssh e.g. \"abc@example.com\"."
    echo "       -n, --name     | The name that you would like to use for setting up things like git e.g. \"John Doe\"."
    echo ""
    echo "To remove the files that you don't need, simply open this installation script and delete their names."
}

# Ensure proper usage.
while :; do
    case $1 in
    -h | -\? | --help)
        show_help
        exit
        ;;
    -c | --copy)
        symlink=0
        shift
        ;;
    -l | --link)
        symlink=1
        shift
        ;;
    -e | --email)
        # TODO: Handle the case where the next argument to email is another option e.g. `-e -c`.
        if [[ "$2" ]]; then
            email=$2
            shift 2
        else
            die "ERROR: \"--email\" requires a non-empty option argument."
        fi
        ;;
    --email=?*)
        email=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --email=) # Handle the case of an empty --email=.
        die "ERROR: \"--email\" requires a non-empty option argument."
        ;;
    -n | --name)
        # TODO: Handle the case where the next argument to name is another option e.g. `-n -c`.
        if [[ "$2" ]]; then
            name=$2
            shift 2
        else
            die "ERROR: \"--name\" requires a non-empty option argument."
        fi
        ;;
    --name=?*)
        name=${1#*=} # Delete everything up to "=" and assign the remainder.
        shift
        ;;
    --name=) # Handle the case of an empty --name=.
        die "ERROR: \"--name\" requires a non-empty option argument."
        ;;
    *) # Default case: No more options, so break out of the loop.
        echo "Symlink = $symlink"
        echo "Email = $email"
        echo "Name = $name"
        echo ""
        if ! [[ $email ]]; then
            die "ERROR: \"--email\" is required."
        fi
        if ! [[ $name ]]; then
            die "ERROR: \"--name\" is required."
        fi
        break
        ;;
    esac
done

# Get the current working directory.
PWD=$(pwd)

# Config files. Remove the files that you don't need.
CONFIG_FILES=(
    ".aliases"
    ".clang-format"
    ".exports"
    ".ideavimrc"
    ".mongoshrc.js"
    ".sqliterc"
    ".tmux.conf"
    ".vimrc"
    ".zprofile"
    ".zshrc"
)

# Path to Neovim config file.
NVIM_DIR="$HOME/.config/nvim"
NVIM_FILE="nvim/init.vim"

# Path to Bat config file.
BAT_DIR="$HOME/.config/bat"
BAT_FILE="bat/config"

# Path to Starship config file.
STARSHIP_DIR="$HOME/.config"
STARSHIP_FILE="starship.toml"

#### TODO: Add backup for Ranger. ####

# Scripts that will run on the start of each session. Remove the ones that you don't need.
STARTUP_SCRIPTS=(
    "greeting.sh"
)

#### TODO: Backup any previously existing files. ####

if [[ $symlink == 0 ]]; then
    echo "Copying config files into $HOME/ ..."
    for file in "${CONFIG_FILES[@]}"; do
        echo "Copying $PWD/config/$file into $HOME/"
        cp $PWD/config/$file $HOME
    done

    # Neovim.
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    cp $PWD/config/$NVIM_FILE $NVIM_DIR

    # Bat.
    if ! [[ -d $BAT_DIR ]]; then
        mkdir -p $BAT_DIR
    fi
    cp $PWD/config/$BAT_FILE $BAT_DIR

    # Starship.
    if ! [[ -d $STARSHIP_DIR ]]; then
        mkdir -p $STARSHIP_DIR
    fi
    cp $PWD/config/$STARSHIP_FILE $STARSHIP_DIR

    echo "Copying startup scripts into $HOME/ ..."
    for file in "${STARTUP_SCRIPTS[@]}"; do
        echo "Copying $PWD/startup_scripts/$file into $HOME/"
        cp $PWD/startup_scripts/$file $HOME
    done
else
    echo "Linking config files into $HOME/ ..."
    for file in "${CONFIG_FILES[@]}"; do
        echo "Symlinking $PWD/config/$file into $HOME/"
        ln -s $PWD/config/$file $HOME
    done

    # Neovim.
    if ! [[ -d $NVIM_DIR ]]; then
        mkdir -p $NVIM_DIR
    fi
    ln -s $PWD/config/$NVIM_FILE $NVIM_DIR

    # Bat.
    if ! [[ -d $BAT_DIR ]]; then
        mkdir -p $BAT_DIR
    fi
    ln -s $PWD/config/$BAT_FILE $BAT_DIR

    # Starship.
    if ! [[ -d $STARSHIP_DIR ]]; then
        mkdir -p $STARSHIP_DIR
    fi
    ln -s $PWD/config/$STARSHIP_FILE $STARSHIP_DIR

    echo "Linking startup scripts into $HOME/ ..."
    for file in "${STARTUP_SCRIPTS[@]}"; do
        echo "Symlinking $PWD/startup_scripts/$file into $HOME/"
        ln -s $PWD/startup_scripts/$file $HOME
    done
fi

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
if [[ $(uname -m) == 'arm64' ]]; then
    # Backup the original file.
    sudo cp /etc/pam.d/sudo /etc/pam.d/sudo.backup
    sudo sed -i "3i auth       sufficient     pam_tid.so" /etc/pam.d/sudo
fi

# File to store any API keys in.
touch ~/.api_keys

# Configure git.
git config --global user.email "$email"
git config --global user.name "$name"
git config --global core.editor "nvim"
git config --global core.filemode false
git config --global status.showuntrackedfiles all
git config --global status.submodulessummary 1
git config --global pull.rebase false
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global merge.conflictstyle "zdiff3"

# Configure `delta` with git (diff-so-fancy emulation mode).
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.features "diff-so-fancy"
git config --global delta.navigate "true"
git config --global delta.line-numbers "true"
git config --global color.ui true

git config --global color.diff-highlight.oldNormal "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta "11"
git config --global color.diff.frag "magenta bold"
git config --global color.diff.func "146 bold"
git config --global color.diff.commit "yellow bold"
git config --global color.diff.old "red bold"
git config --global color.diff.new "green bold"
git config --global color.diff.whitespace "red reverse"

# Create SSH key pair.
ssh-keygen -t ed25519 -C "$email"

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
