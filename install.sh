#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $* == "--help" ]] || [[ $* == "-h" ]]; then
    echo -n "Usage: ./install.sh "
    echo -n "[ -h | --help ] [ -c | --copy] [ -cr | --copy-rc ] [ -lr | --link-rc ] "
    echo    "[ -cs | --copy-scripts ] [ -ls | --link-scripts ] [ -a | --all ]"
    echo    "-h, --help          | Show this help"
    echo    "-c, --copy          | Copy rc files and startup scripts rather than linking"
    echo    "-cr, --copy-rc      | Copy just the rc files"
    echo    "-lr, --link-rc      | Link just the rc files"
    echo    "-cs, --copy-scripts | Copy just the startup scripts"
    echo    "-ls, --link-scripts | Link just the startup scripts"
    echo    "-a, --all           | Link rc files and startup scripts (default)"
    exit 0
fi

PWD=$(pwd)
case $* in
    --copy|-c)
        echo "Copying config files into $HOME/ ..."
        cp -r $PWD/config/ $HOME/
        echo -e "\nCopying startup scripts into $HOME/ ..."
        cp -r $PWD/startup_scripts/ $HOME/
        ;;
    --copy-rc|-cr)
        echo "Copying config files into $HOME/ ..."
        cp -r $PWD/config/ $HOME/
        ;;
    --link-rc|-lr)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    --copy-scripts|-cs)
        echo "Copying startup scripts into $HOME/ ..."
        cp -r $PWD/startup_scripts/ $HOME/
        ;;
    --link-scripts|-ls)
        echo "Linking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        ;;
    *)
        echo "Linking config files into $HOME/ ..."
        for file in $DIR/config/.??*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
        done
        echo -e "\nLinking startup scripts into $HOME/ ..."
        for file in $DIR/startup_scripts/*
        do
            echo "Symlinking $file into $HOME/"
            ln -s $file $HOME/
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

echo "Installing Homebrew packages..."
bash $PWD/scripts/brew.sh
echo -e "Homebrew packages installed successfully!\n"

echo "Installing Manpages."
bash $PWD/scripts/man.sh
echo -e "Manpages installation successful!\n"

echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo -e "Oh-my-zsh installation successful!\n"

# Configure Tmux colors.
echo "Configuring Tmux colors."
tic -x ../config/xterm-256color-italic.terminfo
tic -x ../config/tmux-256color.terminfo
echo -e "Tmux colors configured successfully!\n"

# Zathura can only be installed after installing `xquartz`.
# To install Zathura, you need to install `girara`, `zathura` and
# `zathura-pdf-poppler`. For that, download these packages from the `Releases`
# section on `pwmt` GitHub site and calculate their sha sums that are mentioned
# in `/usr/local/Homebrew/Library/Taps/zegervdv/homebrew-zathura/package-name`.
# And make appropriate changes to those files. Then run the following:
# brew install girara
# brew install zathura
# brew install zathura-pdf-poppler
echo "Please install Zathura as mentioned in the script"

